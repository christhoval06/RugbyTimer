//
//  MatchStats.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/09/26.
//

import Foundation

/// How a team scored: tries, penalty tries, conversions, penalty goals and drop goals.
nonisolated public struct ScoreBreakdown: Equatable {
    public var tries = 0
    /// Awarded tries (+7, no conversion attempt).
    public var penaltyTries = 0
    public var conversions = 0
    public var penalties = 0
    public var dropGoals = 0
    public var points = 0
}

nonisolated public enum MatchResult: Equatable {
    case win(team: String, margin: Int)
    case draw
}

/// Pure match statistics derived from the event log, shared by iPhone and Watch.
nonisolated public enum MatchStats {
    static let halfTimeWhistle = "HALF-TIME WHISTLE"

    public static func breakdown(of events: [MatchEvent], team: String) -> ScoreBreakdown {
        events.reduce(into: ScoreBreakdown()) { total, event in
            guard event.teamName == team, case .tryScore(let points) = event.type else { return }
            total.points += points
            // Descriptions stay English (synced across devices); points break ties for older events.
            let text = event.description.lowercased()
            if text.hasPrefix("penalty try") || points == 7 { // l10n-ignore: synced English
                total.penaltyTries += 1
            } else if text.hasPrefix("conversion") || (points == 2 && !text.hasPrefix("try")) {
                total.conversions += 1
            } else if text.hasPrefix("drop") {
                total.dropGoals += 1
            } else if text.hasPrefix("penalty") || points == 3 {
                total.penalties += 1
            } else {
                total.tries += 1
            }
        }
    }

    /// Points per half, split at the half-time whistle. `nil` until half-time is recorded.
    public static func scoreByHalf(of events: [MatchEvent], home: String, away: String)
        -> (firstHalf: (home: Int, away: Int), secondHalf: (home: Int, away: Int))? {
        guard let split = events.firstIndex(where: { $0.type == .sub && $0.description == halfTimeWhistle }) else {
            return nil
        }
        let first = Array(events[..<split])
        let second = Array(events[split...])
        return (
            (breakdown(of: first, team: home).points, breakdown(of: first, team: away).points),
            (breakdown(of: second, team: home).points, breakdown(of: second, team: away).points)
        )
    }

    /// Seconds played after the clock reached zero in each half, from the whistle events.
    /// A half is nil until its whistle is recorded (or when an older version recorded it).
    public static func timePastClock(of events: [MatchEvent]) -> (firstHalf: Int?, secondHalf: Int?) {
        func overtime(_ whistle: String) -> Int? {
            events.first { $0.type == .sub && $0.description == whistle }?.overtimeSeconds
        }
        return (overtime(halfTimeWhistle), overtime("FULL-TIME WHISTLE"))
    }

    public static func result(home: String, away: String, homeScore: Int, awayScore: Int) -> MatchResult {
        if homeScore == awayScore { return .draw }
        return homeScore > awayScore
            ? .win(team: home, margin: homeScore - awayScore)
            : .win(team: away, margin: awayScore - homeScore)
    }

    /// Players who are still off when play restarts: yellow cards with time left, and red cards.
    public static func carriedSinBins(_ cards: [MatchCard]) -> [MatchCard] {
        cards.filter { $0.type == .red || !$0.isExpired }
    }
}
