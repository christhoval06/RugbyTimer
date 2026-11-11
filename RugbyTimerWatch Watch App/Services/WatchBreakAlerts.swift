import Foundation
import UserNotifications
import WatchKit

/// Buzzes the referee near the end of the half-time interval: one minute left, and break over.
/// While the app is on screen it plays haptics itself (banners are suppressed in the
/// foreground); local notifications cover the case where watchOS has suspended the app.
final class WatchBreakAlerts {
    private static let oneMinuteID = "match.break.one-minute"
    private static let breakOverID = "match.break.over"

    private let notificationCenter: UNUserNotificationCenter
    private var timers: [Timer] = []
    private var scheduledEnd: Date?

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    /// Schedules alerts for `endsAt`, or clears them when the break is over or never started.
    func sync(endsAt: Date?) {
        guard endsAt != scheduledEnd else { return }
        cancel()
        scheduledEnd = endsAt
        guard let endsAt else { return }

        arm(at: endsAt.addingTimeInterval(-60), id: Self.oneMinuteID,
            title: String(appLocalized: "Break: 1 minute left"),
            body: String(appLocalized: "Get the teams ready for the second half."),
            haptic: { HapticService.playSinBinExpired() })
        arm(at: endsAt, id: Self.breakOverID,
            title: String(appLocalized: "Break over"),
            body: String(appLocalized: "Call the teams back for the second-half kick-off."),
            haptic: { HapticService.playTimeUp() })
    }

    private func arm(at date: Date, id: String, title: String, body: String, haptic: @escaping @MainActor () -> Void) {
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }

        let timer = Timer(fire: date, interval: 0, repeats: false) { _ in
            // The timer is on the main run loop. A suspended app gets the notification instead;
            // avoid a double buzz.
            MainActor.assumeIsolated {
                if WKApplication.shared().applicationState == .active { haptic() }
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        timers.append(timer)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        notificationCenter.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func cancel() {
        timers.forEach { $0.invalidate() }
        timers.removeAll()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [Self.oneMinuteID, Self.breakOverID])
    }
}
