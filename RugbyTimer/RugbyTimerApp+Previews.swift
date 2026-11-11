//
//  RugbyTimerApp+Previews.swift
//  RugbyTimer
//

import SwiftUI

// MARK: - iPhone App Previews
#Preview("iPhone Flow - Setup Screen") {
    let state = AppState()
    state.currentScreen = .setup
    return SetupView(
        homeTeamName: .constant("Rangers RFC"),
        awayTeamName: .constant("City Lions"),
        selectedDurationSeconds: .constant(2400),
        sinBinDurationSeconds: .constant(600),
        isWatchSynced: true,
        watchName: "APPLE WATCH ULTRA",
        watchBattery: 98,
        onPrepareMatch: {}
    )
    .environmentObject(AppSettings())
    .environmentObject(MatchHistory(storage: InMemoryMatchHistoryStorage()))
    .preferredColorScheme(.dark)
}

#Preview("iPhone Flow - Live Match Screen") {
    let state = AppState()
    state.currentScreen = .liveMatch
    return LiveMatchView(
        timerService: state.timerService,
        activeCards: [
            MatchCard(teamName: "Rangers RFC", playerNumber: 8, type: .yellow, durationSeconds: 540)
        ],
        homeTeamName: state.homeTeamName,
        awayTeamName: state.awayTeamName,
        matchPeriod: .firstHalf,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {}
    )
    .preferredColorScheme(.dark)
}
