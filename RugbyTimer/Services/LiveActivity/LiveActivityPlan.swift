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

    static func action(for period: MatchPeriod, matchID: UUID?, activityMatchID: UUID?) -> LiveActivityPlan {
        let isLive = period.isPlaying || period.isBreak
        guard let activityMatchID else { return isLive && matchID != nil ? .start : .none }
        guard activityMatchID == matchID else { return isLive ? .replace : .end(keepsFinalScore: false) }
        if isLive { return .update }
        return .end(keepsFinalScore: period == .fullTime)
    }
}
