import SwiftUI

#Preview("Live Match View - H1") {
    LiveMatchView(
        timerService: MatchTimerService(initialSeconds: 2345),
        activeCards: [
            MatchCard(teamName: "Rangers RFC", playerNumber: 8, type: .yellow, durationSeconds: 412),
            MatchCard(teamName: "City Lions", playerNumber: 13, type: .red)
        ],
        matchEvents: [
            MatchEvent(minute: 6, teamName: "Rangers RFC", playerNumber: 11, type: .tryScore(points: 5), description: "Try scored (+5)"),
            MatchEvent(minute: 7, teamName: "Rangers RFC", playerNumber: 10, type: .tryScore(points: 2), description: "Conversion (+2)"),
            MatchEvent(minute: 15, teamName: "City Lions", type: .tryScore(points: 5), description: "Try scored (+5)"),
            MatchEvent(minute: 22, teamName: "Rangers RFC", playerNumber: 10, type: .tryScore(points: 5), description: "Try scored (+5)"),
            MatchEvent(minute: 29, teamName: "City Lions", playerNumber: 15, type: .tryScore(points: 2), description: "Conversion (+2)")
        ],
        homeTeamName: "Rangers RFC",
        awayTeamName: "City Lions",
        matchPeriod: .firstHalf,
        homeScore: 12,
        awayScore: 7,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Live Match View - Pre-Match") {
    LiveMatchView(
        timerService: MatchTimerService(initialSeconds: 2400),
        activeCards: [],
        homeTeamName: "Rangers RFC",
        awayTeamName: "City Lions",
        matchPeriod: .preMatch,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {},
        onReturnToSetup: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Live Match View - iPhone-only H2") {
    LiveMatchView(
        timerService: MatchTimerService(initialSeconds: 1500),
        activeCards: [MatchCard(teamName: "City Lions", playerNumber: 6, type: .yellow, durationSeconds: 380)],
        homeTeamName: "Rangers RFC",
        awayTeamName: "City Lions",
        matchPeriod: .secondHalf,
        homeScore: 17,
        awayScore: 10,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {},
        phoneControls: LiveMatchControls(
            onKickOff: {}, onToggleClock: {}, onEndPeriod: {}, onStartSecondHalf: {},
            onScore: { _, _, _, _ in }, onCard: { _, _, _ in }
        )
    )
    .preferredColorScheme(.dark)
}

#Preview("Live Match View - Full Time") {
    LiveMatchView(
        timerService: MatchTimerService(initialSeconds: 0),
        activeCards: [],
        matchEvents: [
            MatchEvent(minute: 14, teamName: "Rangers RFC", playerNumber: 14, type: .tryScore(points: 5), description: "Try scored (+5)"),
            MatchEvent(minute: 28, teamName: "Rangers RFC", playerNumber: 8, type: .yellowCard, description: "Yellow Card (Sin-Bin) - #8"),
            MatchEvent(minute: 40, teamName: "OFFICIAL", type: .sub, description: "HALF-TIME WHISTLE"),
            MatchEvent(minute: 80, teamName: "OFFICIAL", type: .sub, description: "FULL-TIME WHISTLE")
        ],
        homeTeamName: "Rangers RFC",
        awayTeamName: "City Lions",
        matchPeriod: .fullTime,
        homeScore: 5,
        awayScore: 0,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {},
        onReturnToSetup: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Live Match View - Half-Time") {
    LiveMatchView(
        timerService: MatchTimerService(initialSeconds: 0),
        activeCards: [],
        homeTeamName: "Rangers RFC",
        awayTeamName: "City Lions",
        matchPeriod: .halfTime,
        homeScore: 12,
        awayScore: 7,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Live Match View - iPhone Landscape", traits: .landscapeLeft) {
    LiveMatchView(
        timerService: MatchTimerService(initialSeconds: 1500),
        activeCards: [MatchCard(teamName: "City Lions", playerNumber: 6, type: .yellow, durationSeconds: 380)],
        matchEvents: [
            MatchEvent(minute: 46, teamName: "Rangers RFC", playerNumber: 11, type: .tryScore(points: 5), description: "Try scored (+5)")
        ],
        homeTeamName: "Rangers RFC",
        awayTeamName: "City Lions",
        matchPeriod: .secondHalf,
        homeScore: 17,
        awayScore: 10,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {},
        phoneControls: LiveMatchControls(
            onKickOff: {}, onToggleClock: {}, onEndPeriod: {}, onStartSecondHalf: {},
            onScore: { _, _, _, _ in }, onCard: { _, _, _ in }
        )
    )
    .preferredColorScheme(.dark)
}
