//
//  AppState+PhoneControls.swift
//  RugbyTimer
//

import Foundation

/// iPhone-only mode: the live screen's controls, wired to this match.
extension AppState {
    var phoneControls: LiveMatchControls {
        var controls = LiveMatchControls(
            onKickOff: { [weak self] in self?.startMatch() },
            onToggleClock: { [weak self] in self?.toggleClock() },
            onEndPeriod: { [weak self] in self?.endPeriod() },
            onStartSecondHalf: { [weak self] in self?.startSecondHalf() },
            onScore: { [weak self] team, player, points, description in
                self?.recordScore(team: team, playerNumber: player, points: points, description: description)
            },
            onCard: { [weak self] team, player, sanction in self?.issue(sanction, team: team, playerNum: player) }
        )
        controls.lastEntry = matchEvents.last
        controls.matchEvents = matchEvents
        controls.twentyMinuteRedEnabled = twentyMinuteRedEnabled
        controls.onInjury = { [weak self] in self?.startInjury($0, team: $1, playerNum: $2) }
        controls.onUndo = { [weak self] in self?.undoLastEntry() }
        controls.onConcede = { [weak self] in self?.concede($0, team: $1) }
        controls.nextExtraPeriod = nextExtraPeriod
        controls.onStartExtraPeriod = { [weak self] in self?.startExtraPeriod() }
        controls.onEndMatch = { [weak self] in self?.endMatch() }
        return controls
    }
}
