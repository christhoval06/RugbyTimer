//
//  AppState+CoinToss.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// True on the Watch while Coin toss is on and the toss has not happened yet:
    /// the ready screen shows the toss instead of the kick-off button.
    /// iPhone-only matches have no Watch toss, so they never wait for one.
    public var needsCoinToss: Bool {
        coinTossEnabled && coinToss == nil && !isPhoneHosted && matchPeriod == .preMatch
    }

    /// The team kicking off the given half, from the coin toss; nil without a toss.
    public func kickOffTeamName(for period: MatchPeriod) -> String? {
        // Extra time has its own toss, which isn't recorded here.
        guard let coinToss, !period.isExtraTime else { return nil }
        let side = period == .halfTime || period == .secondHalf
            ? coinToss.secondHalfKickOff : coinToss.firstHalfKickOff
        return coinToss.teamName(side, home: homeTeamName, away: awayTeamName)
    }

    /// Saves the toss done on the Watch before kick-off. It becomes the first match record
    /// entry and reaches the iPhone with the next snapshot. Redoing the toss replaces it.
    public func recordCoinToss(_ result: CoinTossResult) {
        guard coinTossEnabled, matchPeriod == .preMatch else { return }
        coinToss = result
        matchEvents.removeAll(where: CoinTossResult.isTossEvent)
        matchEvents.insert(MatchEvent(
            minute: 0,
            teamName: result.teamName(result.winner, home: homeTeamName, away: awayTeamName),
            type: .sub,
            description: result.eventDescription
        ), at: 0)
        publishWatchSnapshot()
    }
}
