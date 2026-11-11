import SwiftUI

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
