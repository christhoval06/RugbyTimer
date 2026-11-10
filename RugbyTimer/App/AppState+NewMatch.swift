//
//  AppState+NewMatch.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// iPhone "NEW MATCH SETUP" / "MATCH SETUP": back to the Setup screen. When the match
    /// ran on the Watch, the Watch goes back to "Set up on iPhone" too, ready for the next setup.
    public func returnToSetup() {
        currentScreen = .setup
        guard !isPhoneHosted, let matchID,
              matchPeriod == .preMatch || matchPeriod == .fullTime else { return }
        // A late snapshot of this match must not pull the iPhone back to the live screen.
        dismissedMatchID = matchID
        connectivityService.sendMatchReset(matchID: matchID)
    }

    /// Watch: the iPhone moved on from this match. A reset for another match, or one that
    /// arrives while a match is being played, is ignored, so play is never wiped.
    func receiveMatchReset(_ id: UUID) {
        guard id == matchID, matchPeriod == .preMatch || matchPeriod == .fullTime else { return }
        matchID = nil
        resetMatchData()
        connectivityService.clearMatchSnapshot()
    }

    static let dismissedSetupKey = "watch.dismissedSetupID" // l10n-ignore: defaults key

    /// Watch: the iPhone setup the referee left on the Watch (CHANGE SETUP / NEW MATCH).
    /// Kept across launches, so the iPhone resending it doesn't bring it back.
    var dismissedConfigurationID: UUID? {
        get { UserDefaults.standard.string(forKey: Self.dismissedSetupKey).flatMap(UUID.init(uuidString:)) }
        set { UserDefaults.standard.set(newValue?.uuidString, forKey: Self.dismissedSetupKey) }
    }
}
