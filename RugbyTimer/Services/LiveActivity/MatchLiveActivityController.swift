import ActivityKit
import Combine
import Foundation
import OSLog
import UIKit

/// Runs the match's Live Activity: starts it when the match is set up, updates it when the score,
/// period, clock state or cards change, keeps the final score at full time, and ends it when the
/// match is left. The Lock Screen counts the clock by itself, so it is never updated every second.
final class MatchLiveActivityController {
    private static let finalScoreLingers: TimeInterval = 30 * 60
    private static let log = Logger(subsystem: "dev.christhoval.apps.RugbyTimer", category: "LiveActivity") // l10n-ignore
    private var subscriptions = Set<AnyCancellable>()
    private weak var appState: AppState?
    private var activity: Activity<MatchActivityAttributes>?

    func attach(to appState: AppState) {
        guard self.appState == nil else { return }
        self.appState = appState
        // After a relaunch (crash recovery), carry on with the activity already on screen.
        activity = Activity<MatchActivityAttributes>.activities.first
        appState.glanceChanges
            .combineLatest(appState.$currentScreen.removeDuplicates())
            .sink { [weak self] _, _ in self?.refresh() }
            .store(in: &subscriptions)
        // A start refused in the background (iOS only starts activities from the foreground) is retried here.
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &subscriptions)
    }

    private func refresh() {
        guard let appState else { return }
        let glance = appState.matchGlance
        let content = ActivityContent(state: glance, staleDate: glance.clockEndsAt ?? glance.breakEndsAt)
        let plan = LiveActivityPlan.action(for: appState.matchPeriod, matchID: appState.matchID,
                                           isMatchShown: appState.currentScreen != .setup,
                                           activityMatchID: activity?.attributes.matchID)
        switch plan {
        case .none:
            break
        case .start:
            start(content, matchID: appState.matchID)
        case .update:
            guard let activity else { return }
            Task { await activity.update(content) }
        case .end(let keepsFinalScore):
            end(content, dismissal: keepsFinalScore ? .after(Date().addingTimeInterval(Self.finalScoreLingers)) : .immediate)
        case .replace:
            end(content, dismissal: .immediate)
            start(content, matchID: appState.matchID)
        }
    }

    private func start(_ content: ActivityContent<MatchGlance>, matchID: UUID?) {
        guard let matchID else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            Self.log.notice("Live Activities are turned off for Rugby Timer in Settings")
            return
        }
        do {
            activity = try Activity.request(attributes: MatchActivityAttributes(matchID: matchID), content: content)
        } catch {
            Self.log.error("Live Activity not started: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func end(_ content: ActivityContent<MatchGlance>, dismissal: ActivityUIDismissalPolicy) {
        guard let activity else { return }
        self.activity = nil
        Task { await activity.end(content, dismissalPolicy: dismissal) }
    }
}
