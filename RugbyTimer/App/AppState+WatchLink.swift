import Foundation

extension AppState {
    /// The Watch link to watch on the iPhone live screen; nil when no Watch link matters
    /// (iPhone-only mode, no match set up, or the match is over).
    public var watchLinkStatus: WatchLinkStatus? {
        guard !isPhoneHosted, hasConfiguredMatch, matchPeriod != .fullTime else { return nil }
        return WatchLinkStatus(
            isReachable: connectivityService.isWatchReachable,
            lastSyncAt: lastWatchSyncAt,
            isClockRunning: timerService.isRunning
        )
    }
}
