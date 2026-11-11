import ActivityKit
import Combine
import Foundation

/// Runs the match's Live Activity: starts it at kick-off, updates it when the score, period,
/// clock state or cards change, and ends it at full time or when the match is left.
/// The Lock Screen counts the clock by itself, so it is never updated every second.
final class MatchLiveActivityController {
    private static let finalScoreLingers: TimeInterval = 30 * 60
    private var subscription: AnyCancellable?
    private var activity: Activity<MatchActivityAttributes>?

    func attach(to appState: AppState) {
        guard subscription == nil else { return }
        // After a relaunch (crash recovery), carry on with the activity already on screen.
        activity = Activity<MatchActivityAttributes>.activities.first
        subscription = appState.glanceChanges.sink { [weak self, weak appState] glance in
            guard let self, let appState else { return }
            self.apply(glance, period: appState.matchPeriod, matchID: appState.matchID)
        }
    }

    private func apply(_ glance: MatchGlance, period: MatchPeriod, matchID: UUID?) {
        let content = ActivityContent(state: glance, staleDate: glance.clockEndsAt ?? glance.breakEndsAt)
        switch LiveActivityPlan.action(for: period, matchID: matchID, activityMatchID: activity?.attributes.matchID) {
        case .none:
            break
        case .start:
            start(content, matchID: matchID)
        case .update:
            guard let activity else { return }
            Task { await activity.update(content) }
        case .end(let keepsFinalScore):
            end(content, dismissal: keepsFinalScore ? .after(Date().addingTimeInterval(Self.finalScoreLingers)) : .immediate)
        case .replace:
            end(content, dismissal: .immediate)
            start(content, matchID: matchID)
        }
    }

    private func start(_ content: ActivityContent<MatchGlance>, matchID: UUID?) {
        guard let matchID, ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        activity = try? Activity.request(attributes: MatchActivityAttributes(matchID: matchID), content: content)
    }

    private func end(_ content: ActivityContent<MatchGlance>, dismissal: ActivityUIDismissalPolicy) {
        guard let activity else { return }
        self.activity = nil
        Task { await activity.end(content, dismissalPolicy: dismissal) }
    }
}
