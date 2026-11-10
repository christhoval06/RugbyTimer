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
        let elapsedSeconds = matchDurationSeconds - timerService.clockSeconds
        // Second-half events continue the match minute count (41', 42', ...) instead of restarting at 1'.
        let halfOffset = matchPeriod == .secondHalf ? matchDurationSeconds / 60 : 0
        return halfOffset + max(1, elapsedSeconds / 60)
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
            description: description
        )
        matchEvents.append(event)
        publishWatchSnapshot()
    }
}
