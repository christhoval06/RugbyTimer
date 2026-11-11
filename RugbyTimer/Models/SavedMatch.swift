//
//  SavedMatch.swift
//  RugbyTimer
//

import Foundation

/// Everything needed to pick a match back up after the app is closed or crashes:
/// the setup, the score, sin-bins, the record and the clock.
public struct SavedMatch: Codable, Equatable {
    public var matchID: UUID
    public var isWatchOnlyMatch: Bool
    public var isPhoneHosted: Bool
    public var lastAppliedConfigurationID: UUID?

    public var home: String
    public var away: String
    public var halfSeconds: Int
    public var sinBinSeconds: Int
    public var maxPlayerNumber: Int
    public var tapLockEnabled: Bool
    public var coinTossEnabled: Bool
    public var halfTimeBreakSeconds: Int
    public var twentyMinuteRedEnabled: Bool? = nil
    public var halfTimeStartedAt: Date?
    public var coinToss: CoinTossResult?

    public var period: MatchPeriod
    public var homeScore: Int
    public var awayScore: Int
    public var cards: [MatchCard]
    /// The clock reading the sin-bins were last counted to, so they catch up after a relaunch.
    public var cardsClock: Int
    public var events: [MatchEvent]

    public var clockSeconds: Int
    /// Set while the clock runs: when the period reaches zero.
    public var clockEndDate: Date?
}
