import ActivityKit
import Foundation

/// The iPhone Live Activity for a match: the Lock Screen and Dynamic Island show its `MatchGlance`.
nonisolated struct MatchActivityAttributes: ActivityAttributes {
    typealias ContentState = MatchGlance

    /// The match this activity follows, so a new match replaces it.
    let matchID: UUID
}
