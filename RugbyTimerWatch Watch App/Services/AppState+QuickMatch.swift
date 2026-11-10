import Foundation

/// Quick Match: a match set up and run on the Watch alone, without the iPhone.
/// It is never sent to the iPhone, so the iPhone has no record of it.
extension AppState {
    /// A finished match, or one not yet kicked off, can be left for the Watch main screen.
    var canLeaveMatch: Bool {
        hasConfiguredMatch && (matchPeriod == .preMatch || matchPeriod == .fullTime)
    }

    /// Sets up a Watch-only match between Team A and Team B, ready for kick-off.
    func startQuickMatch(_ setup: WatchQuickSetup) {
        guard !hasConfiguredMatch else { return }
        matchID = UUID()
        isWatchOnlyMatch = true
        homeTeamName = String(appLocalized: "Team A")
        awayTeamName = String(appLocalized: "Team B")
        matchDurationSeconds = setup.halfSeconds
        halfTimeBreakSeconds = setup.halfTimeBreakSeconds
        sinBinDurationSeconds = setup.sinBinSeconds
        tapLockEnabled = setup.tapLockEnabled
        coinTossEnabled = setup.coinTossEnabled
        maxPlayerNumber = MatchEvent.playerNumbers.upperBound
        resetMatchData()
    }

    /// Back to the Watch main screen (Set up on iPhone, or Quick Match).
    /// An iPhone setup left this way isn't picked up again when the iPhone resends it.
    func leaveMatch() {
        guard canLeaveMatch else { return }
        if !isWatchOnlyMatch { dismissedConfigurationID = matchID }
        matchID = nil
        isWatchOnlyMatch = false
        resetMatchData()
        connectivityService.clearMatchSnapshot()
    }
}
