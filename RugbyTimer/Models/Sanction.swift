//
//  Sanction.swift
//  RugbyTimer
//

import Foundation

/// What the referee picks when showing a card.
public enum Sanction: Equatable {
    case yellow
    /// Sent off; a replacement can come on after 20 minutes (World Rugby's 20-minute red card).
    case twentyMinuteRed
    case red
    /// A player's second yellow card in the match, shown as a red. It ends their running sin-bin.
    case secondYellowRed

    public var cardType: CardType { self == .yellow ? .yellow : .red }
}

public extension MatchEvent {
    /// True when the player already has a yellow card in this match, so the next one is a red.
    static func hasYellow(in events: [MatchEvent], team: String, playerNumber: Int) -> Bool {
        events.contains { $0.type == .yellowCard && $0.teamName == team && $0.playerNumber == playerNumber }
    }

    /// Red cards recorded as 20-minute reds (the description stays English; it's synced).
    var isTwentyMinuteRed: Bool { type == .redCard && description.hasPrefix(Self.twentyMinuteRedPrefix) }
    var isSecondYellow: Bool { type == .redCard && description.contains(Self.secondYellowMarker) }

    static let twentyMinuteRedPrefix = "20-Minute "
    static let secondYellowMarker = "(Second Yellow)" // l10n-ignore: synced English
}
