//
//  AppState+Penalties.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// Records a penalty or free kick against `team` (the side that infringed).
    /// It can be undone like a score or card.
    public func concede(_ infringement: Infringement, team: String) {
        guard matchPeriod.isPlaying else { return }
        matchEvents.append(MatchEvent(
            minute: currentMinute, teamName: team, type: .sub,
            description: infringement.eventDescription,
            matchSeconds: currentMatchSeconds, recordedAt: Date()
        ))
        HapticService.playStartStop()
        publishWatchSnapshot()
    }

    public func infringements(for team: String) -> InfringementCount {
        InfringementCount.count(in: matchEvents, team: team)
    }
}
