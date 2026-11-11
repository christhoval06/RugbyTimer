//
//  AppState+Substitutions.swift
//  RugbyTimer
//

import Foundation

/// Permanent substitutions, counted per team against `substitutionRules.limit`.
extension AppState {
    /// Substitutions can be made while play runs and at the breaks, when most of them happen.
    public var canSubstitute: Bool {
        substitutionRules.isEnabled && (matchPeriod.isPlaying || matchPeriod.isBreak)
    }

    /// Records `off` leaving and `on` joining for `team`. Undo can take it back.
    public func substitute(team: String, off: Int, on: Int) {
        guard canSubstitute, off != on else { return }
        let substitution = Substitution(off: off, on: on)
        matchEvents.append(MatchEvent(
            minute: currentMinute, teamName: team, type: .sub,
            description: substitution.eventDescription,
            matchSeconds: currentMatchSeconds, recordedAt: Date()
        ))
        HapticService.playStartStop()
        publishWatchSnapshot()
    }

    public func substitutionCount(for team: String) -> Int {
        Substitution.count(in: matchEvents, team: team)
    }

    /// Asked before recording: nil when nothing looks wrong.
    public func substitutionWarning(team: String, off: Int, on: Int) -> SubstitutionWarning? {
        SubstitutionWarning.check(Substitution(off: off, on: on), team: team, rules: substitutionRules,
                                  events: matchEvents, activeCards: activeCards)
    }
}
