//
//  AppState+Injuries.swift
//  RugbyTimer
//

import Foundation

/// Temporary replacements: a head injury assessment (12 minutes) or a blood injury (15 minutes).
extension AppState {
    /// Starts the timer and logs it in the match record. The entry can be undone like a card.
    public func startInjury(_ kind: InjuryKind, team: String, playerNum: Int) {
        let timer = InjuryTimer(teamName: team, playerNumber: playerNum, kind: kind)
        injuryTimers.append(timer)
        matchEvents.append(MatchEvent(
            minute: currentMinute, teamName: team, playerNumber: playerNum, type: .sub,
            description: InjuryTimer.eventDescription(kind, number: playerNum),
            matchSeconds: currentMatchSeconds, recordedAt: Date(), cardID: timer.id
        ))
        HapticService.playCardIssued()
        publishWatchSnapshot()
    }

    /// Ends the timer: the player came back on, or the replacement is now permanent.
    public func endInjury(id: UUID, outcome: InjuryOutcome) {
        guard let index = injuryTimers.firstIndex(where: { $0.id == id }) else { return }
        let timer = injuryTimers.remove(at: index)
        matchEvents.append(MatchEvent(
            minute: currentMinute, teamName: timer.teamName, playerNumber: timer.playerNumber, type: .sub,
            description: InjuryTimer.eventDescription(timer.kind, outcome: outcome, number: timer.playerNumber),
            matchSeconds: currentMatchSeconds
        ))
        HapticService.playStartStop()
        publishWatchSnapshot()
    }
}

public extension MatchEvent {
    /// The start of an HIA or blood replacement (not its outcome), which "Undo last" can take back.
    var startsInjury: Bool {
        type == .sub && cardID != nil && InjuryTimer.localizedDescription(of: description) != nil
    }
}
