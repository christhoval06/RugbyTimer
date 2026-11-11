import Foundation

/// What the referee can do about a player off the field, on the device running the match.
/// Lists get nil instead when they're read-only (summaries, or an iPhone mirroring the Watch).
public struct OffFieldActions {
    /// Ends a sin-bin or 20-minute red countdown now.
    public var endSinBin: (UUID) -> Void
    /// Fixes the shirt number on a card.
    public var fixNumber: (UUID, Int) -> Void
    /// Ends an HIA or blood timer: back on, or permanently replaced.
    public var endInjury: (UUID, InjuryOutcome) -> Void

    public init(
        endSinBin: @escaping (UUID) -> Void,
        fixNumber: @escaping (UUID, Int) -> Void,
        endInjury: @escaping (UUID, InjuryOutcome) -> Void
    ) {
        self.endSinBin = endSinBin
        self.fixNumber = fixNumber
        self.endInjury = endInjury
    }

    public static let preview = OffFieldActions(endSinBin: { _ in }, fixNumber: { _, _ in }, endInjury: { _, _ in })
}
