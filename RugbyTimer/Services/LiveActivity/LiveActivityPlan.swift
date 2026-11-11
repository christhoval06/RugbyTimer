import Foundation

/// What to do with the Live Activity when the match changes. Pure, so it's unit-tested.
nonisolated enum LiveActivityPlan: Equatable {
    case none
    case start
    case update
    /// End it; at full time the final score stays on the Lock Screen for a while.
    case end(keepsFinalScore: Bool)
    /// A different match is on: end the old activity and start one for this match.
    case replace

    /// - Parameter isMatchShown: the live match screen is up (not Match Setup).
    ///
    /// iOS only lets the app *start* an activity while it's on screen, so it starts as soon as the
    /// match is set up (READY, 0–0), not at kick-off: when the Watch runs the match, kick-off
    /// happens on the Watch with the iPhone in a pocket. Updates from the background are allowed.
    static func action(for period: MatchPeriod, matchID: UUID?, isMatchShown: Bool,
                       activityMatchID: UUID?) -> LiveActivityPlan {
        let isOn = isMatchShown && matchID != nil && (period == .preMatch || period.isPlaying || period.isBreak)
        guard let activityMatchID else { return isOn ? .start : .none }
        guard activityMatchID == matchID else { return isOn ? .replace : .end(keepsFinalScore: false) }
        if isOn { return .update }
        return .end(keepsFinalScore: period == .fullTime)
    }
}
