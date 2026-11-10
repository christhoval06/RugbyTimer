import Foundation

/// Actions the live screen offers when the iPhone runs the match itself (iPhone-only mode).
/// `LiveMatchView` shows no controls when this is nil, because the Watch is in charge.
public struct LiveMatchControls {
    public var onKickOff: () -> Void
    public var onToggleClock: () -> Void
    public var onEndPeriod: () -> Void
    public var onStartSecondHalf: () -> Void
    /// Team, optional scorer number, points, description.
    public var onScore: (String, Int?, Int, String) -> Void
    public var onCard: (String, Int, CardType) -> Void

    public init(
        onKickOff: @escaping () -> Void,
        onToggleClock: @escaping () -> Void,
        onEndPeriod: @escaping () -> Void,
        onStartSecondHalf: @escaping () -> Void,
        onScore: @escaping (String, Int?, Int, String) -> Void,
        onCard: @escaping (String, Int, CardType) -> Void
    ) {
        self.onKickOff = onKickOff
        self.onToggleClock = onToggleClock
        self.onEndPeriod = onEndPeriod
        self.onStartSecondHalf = onStartSecondHalf
        self.onScore = onScore
        self.onCard = onCard
    }

    /// Scoring options, matching the Watch score page so records read the same on both devices.
    /// `id` and `description` stay English: tests find tiles by id, and the description is synced to the Watch.
    static let scoreTypes: [(id: String, label: LocalizedStringResource, points: Int, description: String)] = [
        ("TRY", "TRY", 5, "Try scored (+5)"),
        ("CONVERSION", "CONVERSION", 2, "Conversion (+2)"),
        ("PENALTY", "PENALTY", 3, "Penalty goal (+3)"),
        ("DROPGOAL", "DROP GOAL", 3, "Drop goal (+3)") // l10n-ignore: id and description are English by design
    ]
}
