//
//  AppState+Scoring.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    public func incrementScore(forHome: Bool, points: Int) {
        if forHome {
            homeScore += points
        } else {
            awayScore += points
        }
    }

    var currentMinute: Int {
        let elapsedSeconds = currentPeriodSeconds - timerService.clockSeconds
        // Later periods continue the match minute count (41', 42', ... 81') instead of restarting at 1'.
        return periodOffsetSeconds / 60 + max(1, elapsedSeconds / 60)
    }

    /// Seconds since kick-off; the second half continues from the end of the first.
    var currentMatchSeconds: Int {
        let elapsedSeconds = max(0, currentPeriodSeconds - timerService.clockSeconds)
        return periodOffsetSeconds + elapsedSeconds
    }

    /// `playerNumber` is optional: the referee may record points without naming the scorer.
    public func recordScore(team: String, playerNumber: Int? = nil, points: Int, description: String) {
        if team == homeTeamName {
            homeScore += points
        } else {
            awayScore += points
        }

        let event = MatchEvent(
            minute: currentMinute,
            teamName: team,
            playerNumber: playerNumber,
            type: .tryScore(points: points),
            description: description,
            matchSeconds: currentMatchSeconds,
            recordedAt: Date()
        )
        matchEvents.append(event)
        publishWatchSnapshot()
    }
}
