import Foundation

/// Whether the iPhone mirror is still hearing from the referee's Watch.
///
/// While the Watch clock runs it reports every second, so a few silent seconds mean the link
/// is gone even if WatchConnectivity has not noticed yet. With the clock stopped the Watch
/// goes quiet on purpose, so only a lost connection counts then.
public struct WatchLinkStatus: Equatable {
    public static let silenceLimit: TimeInterval = 5

    public var isReachable: Bool
    public var lastSyncAt: Date?
    public var isClockRunning: Bool

    public init(isReachable: Bool, lastSyncAt: Date?, isClockRunning: Bool) {
        self.isReachable = isReachable
        self.lastSyncAt = lastSyncAt
        self.isClockRunning = isClockRunning
    }

    public func isLost(at now: Date) -> Bool {
        guard let lastSyncAt else { return !isReachable }
        let isSilent = now.timeIntervalSince(lastSyncAt) > Self.silenceLimit
        return isClockRunning ? isSilent : isSilent && !isReachable
    }

    /// Whole seconds since the last Watch update, or nil if none has arrived for this match.
    public func secondsSinceSync(at now: Date) -> Int? {
        lastSyncAt.map { max(0, Int(now.timeIntervalSince($0))) }
    }
}
