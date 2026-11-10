//
//  CoinToss.swift
//  RugbyTimer
//

import Foundation

public enum CoinFace: String, Codable, CaseIterable {
    case heads
    case tails
}

public enum TossSide: String, Codable {
    case home
    case away

    public var opponent: TossSide { self == .home ? .away : .home }
}

/// What the captain who won the toss decides.
public enum TossChoice: String, Codable {
    case kickOff
    case chooseEnd
}

/// The pre-match coin toss: the toss winner kicks off or picks an end, and the other
/// team kicks off the second half.
public struct CoinTossResult: Codable, Equatable {
    public var caller: TossSide
    public var call: CoinFace
    public var outcome: CoinFace
    public var choice: TossChoice

    public init(caller: TossSide, call: CoinFace, outcome: CoinFace, choice: TossChoice) {
        self.caller = caller
        self.call = call
        self.outcome = outcome
        self.choice = choice
    }

    /// A toss done with a physical coin: only the winner and their decision are recorded.
    public static func recorded(winner: TossSide, choice: TossChoice) -> CoinTossResult {
        CoinTossResult(caller: winner, call: .heads, outcome: .heads, choice: choice)
    }

    public var winner: TossSide { call == outcome ? caller : caller.opponent }
    public var firstHalfKickOff: TossSide { choice == .kickOff ? winner : winner.opponent }
    public var secondHalfKickOff: TossSide { firstHalfKickOff.opponent }

    public func teamName(_ side: TossSide, home: String, away: String) -> String {
        side == .home ? home : away
    }

    /// Synced to the Watch in English, like the other match record events.
    public var eventDescription: String {
        choice == .kickOff ? Self.wonKickOff : Self.wonChoseEnd
    }

    static let wonKickOff = "Won the toss · kicks off"
    static let wonChoseEnd = "Won the toss · chose an end"

    static func isTossEvent(_ event: MatchEvent) -> Bool {
        event.type == .sub && (event.description == wonKickOff || event.description == wonChoseEnd)
    }

    /// Who kicks off each half, read back from the toss entry in a match record
    /// (the Watch break screen only has the events). Nil when no toss was recorded.
    public static func kickOffTeams(in events: [MatchEvent], home: String, away: String)
        -> (firstHalf: String, secondHalf: String)? {
        guard let toss = events.first(where: isTossEvent) else { return nil }
        let other = toss.teamName == home ? away : home
        return toss.description == wonKickOff ? (toss.teamName, other) : (other, toss.teamName)
    }
}
