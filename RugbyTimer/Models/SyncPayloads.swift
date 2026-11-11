//
//  SyncPayloads.swift
//  RugbyTimer
//

import Foundation

/// What the iPhone and Watch send each other through `WatchConnectivityService`.
/// New fields stay optional, so older versions of either app can still decode them.

nonisolated public struct MatchConfiguration: Codable, Equatable {
    public var matchID: UUID
    public var home: String
    public var away: String
    public var duration: Int
    // Optional so setups from an older companion retain the 10-minute default.
    public var sinBinDurationSeconds: Int? = nil
    // Optional so older companions keep the default shirt-number range.
    public var maxPlayerNumber: Int? = nil
    // Optional so older companions keep plain taps on the Watch.
    public var tapLockEnabled: Bool? = nil
    // Optional so older companions skip the Watch coin toss.
    public var coinTossEnabled: Bool? = nil
    // Optional so older companions get the standard 2-minute half-time break.
    public var halfTimeBreakSeconds: Int? = nil
    // Optional so older companions keep full red cards only.
    public var twentyMinuteRedEnabled: Bool? = nil
}

nonisolated public struct MatchSnapshot: Codable, Equatable {
    public var updatedAt = Date()
    public var matchID: UUID
    public var home: String
    public var away: String
    public var duration: Int
    public var period: MatchPeriod
    public var remaining: Int
    public var isRunning: Bool
    public var homeScore: Int
    public var awayScore: Int
    public var cards: [MatchCard]
    public var rejectedConfigurationID: UUID? = nil
    public var sinBinDurationSeconds: Int? = nil
    // Optional so snapshots from an older Watch app keep decoding; the iPhone needs it for the match record.
    public var events: [MatchEvent]? = nil
    // When the running period reaches zero, so the iPhone keeps counting while out of range.
    public var clockEndDate: Date? = nil
    // Optional so snapshots from an older Watch app keep decoding.
    public var injuries: [InjuryTimer]? = nil
}
