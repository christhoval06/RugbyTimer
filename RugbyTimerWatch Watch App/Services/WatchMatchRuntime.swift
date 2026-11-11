import Combine
import Foundation

/// Keeps the Watch match clock alive while the app is not frontmost and makes sure the
/// referee is buzzed when a half or a sin-bin ends, even if watchOS suspends the app.
///
/// - A Rugby workout (`WatchWorkoutSession`) keeps the app running from kick-off to full
///   time and is saved to Health. Without Health access, a `WKExtendedRuntimeSession`
///   (`WatchExtendedSession`) covers each half and the break instead.
/// - Local notifications for every end date (`WatchMatchAlerts`) are the fallback buzz.
final class WatchMatchRuntime: NSObject, ObservableObject {
    private weak var appState: AppState?
    private var subscriptions = Set<AnyCancellable>()
    private let workout = WatchWorkoutSession()
    private let extendedSession = WatchExtendedSession()
    private let alerts = WatchMatchAlerts()
    private let breakAlerts = WatchBreakAlerts()
    /// The Quick Match last handed to the iPhone's history, so it's sent once.
    private var sentFinishedMatchID: UUID?

    func attach(to appState: AppState) {
        guard self.appState !== appState else { return }
        self.appState = appState
        subscriptions.removeAll()
        alerts.activate()

        appState.timerService.$isRunning
            // Cards re-sync when one is added, removed, ended early or renumbered, not on every tick.
            .combineLatest(appState.$matchPeriod,
                           appState.$activeCards.map { $0.map { "\($0.id)\($0.isExpired)\($0.playerNumber)" } }
                               .removeDuplicates(),
                           appState.$halfTimeStartedAt)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.sync() }
            .store(in: &subscriptions)
        appState.$injuryTimers.map { $0.map(\.id) }.removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.sync() }
            .store(in: &subscriptions)
    }

    /// Call when the app becomes active again: catches the clock up and restarts the
    /// background session if watchOS ended it.
    func appDidBecomeActive() {
        appState?.timerService.refresh()
        sync()
    }

    private func sync() {
        guard let appState else { return }
        let period = appState.matchPeriod
        let isPlaying = period.isPlaying
        let isMatchLive = isPlaying || period.isBreak

        if period == .preMatch && appState.hasConfiguredMatch {
            Task { await workout.requestAuthorizationIfNeeded() }
        }
        if isMatchLive && (workout.isActive || workout.isAuthorized) {
            extendedSession.stop()
            Task { [weak self] in
                guard let self, !(await self.workout.start()) else { return }
                self.extendedSession.start()
            }
        } else {
            // The extended session also covers the half-time break so its countdown alerts can play.
            isPlaying || appState.halfTimeBreakEndsAt != nil ? extendedSession.start() : extendedSession.stop()
            // Full time saves the workout; a match left or replaced before then discards it.
            if !isMatchLive && workout.isActive {
                Task { await workout.end(saving: period == .fullTime) }
            }
        }
        sendQuickMatchToHistory(appState)
        alerts.sync(with: appState)
        breakAlerts.sync(endsAt: appState.halfTimeBreakEndsAt)
    }

    /// A Quick Match never syncs while it's played; at full time it goes to the iPhone's history.
    private func sendQuickMatchToHistory(_ appState: AppState) {
        guard appState.isWatchOnlyMatch, let match = appState.finishedMatch,
              match.matchID != sentFinishedMatchID else { return }
        appState.connectivityService.sendFinishedMatch(match)
        sentFinishedMatchID = match.matchID
    }
}
