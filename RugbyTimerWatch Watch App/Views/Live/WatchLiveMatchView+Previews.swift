import SwiftUI

#Preview("First half") {
    WatchLiveMatchView(
        timerService: MatchTimerService(initialSeconds: 2345),
        activeCards: [
            MatchCard(teamName: "Rangers RFC", playerNumber: 8, type: .yellow, durationSeconds: 412),
            MatchCard(teamName: "City Lions", playerNumber: 13, type: .red)
        ],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .firstHalf, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}

#Preview("Time up") {
    let timer = MatchTimerService(initialSeconds: -37)
    WatchLiveMatchView(
        timerService: timer,
        activeCards: [],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .firstHalf, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}

#Preview("Half-time") {
    WatchLiveMatchView(
        timerService: MatchTimerService(initialSeconds: 0),
        activeCards: [],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .halfTime, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}

#Preview("Full time") {
    WatchLiveMatchView(
        timerService: MatchTimerService(initialSeconds: 0),
        activeCards: [],
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        matchPeriod: .fullTime, totalDuration: 2400,
        homeScore: 12, awayScore: 7,
        matchEvents: [
            MatchEvent(minute: 28, teamName: "City Lions", playerNumber: 8, type: .yellowCard, description: "Yellow Card (Sin-Bin) - #8"),
            MatchEvent(minute: 55, teamName: "Rangers RFC", playerNumber: 4, type: .yellowCard, description: "Yellow Card (Sin-Bin) - #4"),
            MatchEvent(minute: 71, teamName: "City Lions", playerNumber: 13, type: .redCard, description: "Red Card (Expulsion) - #13")
        ],
        onAddCard: { _, _, _ in }, onScore: { _, _, _, _ in }, onStartSecondHalf: {}, onEndPeriod: {}
    )
}
