import Foundation
import WatchKit

/// Fallback when Health access was declined: a `WKExtendedRuntimeSession` (physical-therapy
/// background mode) keeps the app running during each half and the half-time break.
/// watchOS limits it to about an hour, so the workout session is preferred.
final class WatchExtendedSession: NSObject {
    private var session: WKExtendedRuntimeSession?

    func start() {
        if let session, session.state == .running || session.state == .scheduled { return }
        // Sessions can only start while the app is active; the runtime retries when it comes back.
        guard WKApplication.shared().applicationState == .active else { return }
        let newSession = WKExtendedRuntimeSession()
        newSession.delegate = self
        newSession.start()
        session = newSession
    }

    func stop() {
        session?.invalidate()
        session = nil
    }
}

extension WatchExtendedSession: WKExtendedRuntimeSessionDelegate {
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
