import Foundation

/// "NEW MATCH SETUP" on iPhone sends the Watch back to its "Set up on iPhone" screen.
///
/// The reset rides in the application context, like the setup, so a Watch that is out of
/// range or closed still gets it the next time it connects. Sending a reset drops the old
/// setup from the context (and a new setup drops the reset), so the two never replay together.
extension WatchConnectivityService {
    static let matchResetKey = "matchReset" // l10n-ignore: wire key

    /// iPhone: tells the Watch that this match's setup is finished with.
    public func sendMatchReset(matchID: UUID) {
        outgoingContext.removeValue(forKey: "configuration") // l10n-ignore: wire key
        outgoingContext[Self.matchResetKey] = matchID.uuidString
        flushContext()
    }

    /// Watch: stops offering the finished match's snapshot to the iPhone.
    public func clearMatchSnapshot() {
        outgoingContext.removeValue(forKey: "snapshot") // l10n-ignore: wire key
        flushContext()
    }

    func receiveMatchReset(from context: [String: Any]) {
        #if os(watchOS)
        if let value = context[Self.matchResetKey] as? String, let id = UUID(uuidString: value) {
            receivedMatchReset = id
        }
        #endif
    }
}
