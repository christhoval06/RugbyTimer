import Combine
import Foundation
import UserNotifications
import WatchKit

/// Keeps the Watch match clock alive while the app is not frontmost and makes sure the
/// referee is buzzed when a half or a sin-bin ends, even if watchOS suspends the app.
///
/// - A `WKExtendedRuntimeSession` (physical-therapy background mode) keeps the process
///   running during each half, so the clock, sin-bins and haptics keep working.
/// - Local notifications scheduled for every end date act as a fallback buzz when
///   the session expires or the process is suspended anyway.
final class WatchMatchRuntime: NSObject, ObservableObject {
    private static let periodEndID = "match.period-end"
    private static let sinBinPrefix = "match.sinbin."

    private weak var appState: AppState?
    private var session: WKExtendedRuntimeSession?
    private var subscriptions = Set<AnyCancellable>()
    private let notificationCenter = UNUserNotificationCenter.current()

    func attach(to appState: AppState) {
        guard self.appState !== appState else { return }
        self.appState = appState
        subscriptions.removeAll()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in }

        appState.timerService.$isRunning
            .combineLatest(appState.$matchPeriod, appState.$activeCards.map { $0.map(\.id) }.removeDuplicates())
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
        let isPlaying = appState.matchPeriod == .firstHalf || appState.matchPeriod == .secondHalf
        isPlaying ? startSessionIfNeeded() : stopSession()
        scheduleAlerts(for: appState)
    }

    // MARK: - Extended runtime session

    private func startSessionIfNeeded() {
        if let session, session.state == .running || session.state == .scheduled { return }
        // Sessions can only start while the app is active; appDidBecomeActive retries later.
        guard WKApplication.shared().applicationState == .active else { return }
        let newSession = WKExtendedRuntimeSession()
        newSession.delegate = self
        newSession.start()
        session = newSession
    }

    private func stopSession() {
        session?.invalidate()
        session = nil
    }

    // MARK: - Fallback notifications

    private func scheduleAlerts(for appState: AppState) {
        let timer = appState.timerService
        let sinBinIDs = appState.activeCards.map { Self.sinBinPrefix + $0.id.uuidString }

        guard timer.isRunning, let endDate = timer.endDate else {
            // Keep a just-fired period-end alert; drop alerts for a clock the referee paused.
            var stale = sinBinIDs
            if timer.timeRemaining > 0 { stale.append(Self.periodEndID) }
            notificationCenter.removePendingNotificationRequests(withIdentifiers: stale)
            return
        }

        schedule(
            id: Self.periodEndID,
            title: String(localized: "Time up"),
            body: appState.matchPeriod == .firstHalf
                ? String(localized: "End of the first half at the next dead ball.")
                : String(localized: "End of the second half at the next dead ball."),
            after: endDate.timeIntervalSinceNow
        )

        for card in appState.activeCards where card.type == .yellow && !card.isExpired {
            schedule(
                id: Self.sinBinPrefix + card.id.uuidString,
                title: String(localized: "Sin-bin over"),
                body: String(localized: "#\(card.playerNumber) \(card.teamName) can return"),
                after: TimeInterval(card.remainingSeconds)
            )
        }
    }

    private func schedule(id: String, title: String, body: String, after interval: TimeInterval) {
        guard interval > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        notificationCenter.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}

extension WatchMatchRuntime: WKExtendedRuntimeSessionDelegate {
    nonisolated func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}

    nonisolated func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        // The scheduled notifications take over once the session ends.
    }

    nonisolated func extendedRuntimeSession(
        _ extendedRuntimeSession: WKExtendedRuntimeSession,
        didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
        error: Error?
    ) {
        Task { @MainActor [weak self] in
            if self?.session === extendedRuntimeSession { self?.session = nil }
        }
    }
}

extension WatchMatchRuntime: UNUserNotificationCenterDelegate {
    // While the app is on screen it plays its own haptics, so suppress the banner.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        []
    }
}
