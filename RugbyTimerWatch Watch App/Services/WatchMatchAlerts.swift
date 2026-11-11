import Foundation
import UserNotifications

/// Local notifications for every end date (the half, each sin-bin): a fallback buzz for when
/// watchOS suspends the app anyway.
final class WatchMatchAlerts: NSObject {
    private static let periodEndID = "match.period-end"
    private static let sinBinPrefix = "match.sinbin."
    private static let injuryPrefix = "match.injury."

    private let center = UNUserNotificationCenter.current()
    /// Sin-bin alerts now pending, so an undone or finished card's alert can be withdrawn.
    private var scheduledSinBinIDs: Set<String> = []
    private var scheduledInjuryIDs: Set<String> = []

    func activate() {
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func sync(with appState: AppState) {
        syncInjuries(appState.injuryTimers)
        let timer = appState.timerService
        let liveCards = appState.activeCards.filter { $0.countsDown && !$0.isExpired }
        let liveIDs = Set(liveCards.map { Self.sinBinPrefix + $0.id.uuidString })

        guard timer.isRunning, let endDate = timer.endDate else {
            // Keep a just-fired period-end alert; drop alerts for a clock the referee paused.
            var stale = Array(scheduledSinBinIDs.union(liveIDs))
            if timer.timeRemaining > 0 { stale.append(Self.periodEndID) }
            center.removePendingNotificationRequests(withIdentifiers: stale)
            scheduledSinBinIDs = []
            return
        }

        center.removePendingNotificationRequests(withIdentifiers: Array(scheduledSinBinIDs.subtracting(liveIDs)))
        scheduledSinBinIDs = liveIDs

        schedule(
            id: Self.periodEndID,
            title: String(appLocalized: "Time up"),
            body: appState.matchPeriod == .firstHalf
                ? String(appLocalized: "End of the first half at the next dead ball.")
                : String(appLocalized: "End of the second half at the next dead ball."),
            after: endDate.timeIntervalSinceNow
        )

        for card in liveCards {
            let isRed = card.type == .red
            schedule(
                id: Self.sinBinPrefix + card.id.uuidString,
                title: isRed ? String(appLocalized: "20 minutes up") : String(appLocalized: "Sin-bin over"),
                body: isRed
                    ? String(appLocalized: "\(card.teamName) can replace #\(card.playerNumber)")
                    : String(appLocalized: "#\(card.playerNumber) \(card.teamName) can return"),
                after: TimeInterval(card.remainingSeconds)
            )
        }
    }

    /// Injury timers run in real time, so their alerts stay scheduled whatever the match clock does.
    private func syncInjuries(_ injuries: [InjuryTimer]) {
        let ids = Set(injuries.map { Self.injuryPrefix + $0.id.uuidString })
        center.removePendingNotificationRequests(withIdentifiers: Array(scheduledInjuryIDs.subtracting(ids)))
        scheduledInjuryIDs = ids
        for injury in injuries {
            schedule(
                id: Self.injuryPrefix + injury.id.uuidString,
                title: injury.kind == .hia ? String(appLocalized: "HIA time up") : String(appLocalized: "Blood time up"),
                body: String(appLocalized: "#\(injury.playerNumber) \(injury.teamName): back on or replaced?"),
                after: injury.endsAt.timeIntervalSinceNow
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
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}

extension WatchMatchAlerts: UNUserNotificationCenterDelegate {
    // While the app is on screen it plays its own haptics for the clock and sin-bins, so their
    // banners are suppressed. Injury timers have no in-app buzz, so theirs still show.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        notification.request.identifier.hasPrefix("match.injury.") ? [.banner, .sound] : [] // l10n-ignore: notification ID
    }
}
