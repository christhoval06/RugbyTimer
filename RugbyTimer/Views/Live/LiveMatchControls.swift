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
    public var onCard: (String, Int, Sanction) -> Void
    /// The latest score or card, offered for undo while its window is open.
    public var lastEntry: MatchEvent?
    public var onUndo: () -> Void = {}
    /// The record so far: the card sheet checks it for a player's second yellow.
    public var matchEvents: [MatchEvent] = []
    /// Offers a 20-minute red, and makes a second yellow one.
    public var twentyMinuteRedEnabled = false
    /// Starts an HIA or blood replacement timer.
    public var onInjury: (InjuryKind, String, Int) -> Void = { _, _, _ in }
    /// Counts a penalty or free kick against a team.
    public var onConcede: (Infringement, String) -> Void = { _, _ in }
    /// Records a substitution: team, number off, number on. `activeCards` feeds its warnings.
    public var onSubstitute: (String, Int, Int) -> Void = { _, _, _ in }
    public var activeCards: [MatchCard] = []
    /// Extra-time break: the period the next kick-off starts, and ending level instead.
    public var nextExtraPeriod: MatchPeriod?
    public var onStartExtraPeriod: () -> Void = {}
    public var onEndMatch: () -> Void = {}

    public init(
        onKickOff: @escaping () -> Void,
        onToggleClock: @escaping () -> Void,
        onEndPeriod: @escaping () -> Void,
        onStartSecondHalf: @escaping () -> Void,
        onScore: @escaping (String, Int?, Int, String) -> Void,
        onCard: @escaping (String, Int, Sanction) -> Void
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
        ("DROPGOAL", "DROP GOAL", 3, "Drop goal (+3)"), // l10n-ignore: id and description are English by design
        ("PENALTYTRY", "PENALTY TRY", 7, "Penalty try (+7)") // l10n-ignore: id and description are English by design
    ]
}
