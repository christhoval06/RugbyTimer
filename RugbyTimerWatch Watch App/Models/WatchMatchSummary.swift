import Foundation

/// Everything the Watch break and result screens read about the match, bundled so pages
/// take one value instead of a long list of parameters.
struct WatchMatchSummary {
    let homeTeamName: String
    let awayTeamName: String
    let homeScore: Int
    let awayScore: Int
    let matchPeriod: MatchPeriod
    let activeCards: [MatchCard]
    let matchEvents: [MatchEvent]

    var result: MatchResult {
        MatchStats.result(home: homeTeamName, away: awayTeamName, homeScore: homeScore, awayScore: awayScore)
    }

    var homeBreakdown: ScoreBreakdown { MatchStats.breakdown(of: matchEvents, team: homeTeamName) }
    var awayBreakdown: ScoreBreakdown { MatchStats.breakdown(of: matchEvents, team: awayTeamName) }

    var scoreByHalf: (firstHalf: (home: Int, away: Int), secondHalf: (home: Int, away: Int))? {
        MatchStats.scoreByHalf(of: matchEvents, home: homeTeamName, away: awayTeamName)
    }

    var carriedSinBins: [MatchCard] { MatchStats.carriedSinBins(activeCards) }

    /// The team kicking off the second half, when a coin toss was recorded.
    var secondHalfKickOff: String? {
        CoinTossResult.kickOffTeams(in: matchEvents, home: homeTeamName, away: awayTeamName)?.secondHalf
    }

    /// True at half-time and full time, when the break/result summaries are shown.
    var isStopped: Bool { matchPeriod == .halfTime || matchPeriod == .fullTime }
}

extension WatchMatchSummary {
    static let preview = WatchMatchSummary(
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        homeScore: 12, awayScore: 7, matchPeriod: .fullTime,
        activeCards: [MatchCard(teamName: "City Lions", playerNumber: 8, type: .yellow, durationSeconds: 252)],
        matchEvents: [
            MatchEvent(minute: 6, teamName: "Rangers RFC", playerNumber: 11, type: .tryScore(points: 5), description: "Try scored (+5)"),
            MatchEvent(minute: 7, teamName: "Rangers RFC", playerNumber: 10, type: .tryScore(points: 2), description: "Conversion (+2)"),
            MatchEvent(minute: 36, teamName: "City Lions", playerNumber: 8, type: .yellowCard, description: "Yellow Card (Sin-Bin) - #8"),
            MatchEvent(minute: 40, teamName: "OFFICIAL", type: .sub, description: "HALF-TIME WHISTLE"),
            MatchEvent(minute: 52, teamName: "City Lions", type: .tryScore(points: 5), description: "Try scored (+5)"),
            MatchEvent(minute: 53, teamName: "City Lions", playerNumber: 15, type: .tryScore(points: 2), description: "Conversion (+2)"),
            MatchEvent(minute: 64, teamName: "Rangers RFC", playerNumber: 10, type: .tryScore(points: 5), description: "Try scored (+5)"),
            MatchEvent(minute: 80, teamName: "OFFICIAL", type: .sub, description: "FULL-TIME WHISTLE")
        ]
    )
}
