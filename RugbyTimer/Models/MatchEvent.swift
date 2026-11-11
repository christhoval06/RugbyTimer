//
//  MatchEvent.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation

nonisolated public enum MatchEventType: Equatable, Codable {
    case tryScore(points: Int) // +5 for try, +2 for conversion, +3 for penalty/drop goal
    case yellowCard
    case redCard
    case sub
}

nonisolated public struct MatchEvent: Identifiable, Equatable, Codable {
    /// Shirt numbers a referee can pick for scorers and sanctions (match-day squad plus extras).
    public static let playerNumbers = 1...40

    public let id: UUID
    public let minute: Int
    public let teamName: String
    public let playerNumber: Int?
    public let type: MatchEventType
    public let description: String
    /// On half-time and full-time whistles: how long play ran after the clock reached zero.
    /// Optional so events from older versions keep decoding.
    public let overtimeSeconds: Int?
    /// Match time of the event in seconds since kick-off (second half continues from the first).
    /// Optional so events from older versions keep decoding; those show the minute only.
    public let matchSeconds: Int?
    /// Wall-clock time the entry was made; drives "Undo last". Nil on older events.
    public let recordedAt: Date?
    /// The sin-bin entry a card event created, so undoing the card removes it too.
    public let cardID: UUID?
    /// Second yellow: the running sin-bin the red card ended, so undoing the red puts it back.
    public let replacedCard: MatchCard?

    public init(
        id: UUID = UUID(),
        minute: Int,
        teamName: String,
        playerNumber: Int? = nil,
        type: MatchEventType,
        description: String,
        overtimeSeconds: Int? = nil,
        matchSeconds: Int? = nil,
        recordedAt: Date? = nil,
        cardID: UUID? = nil,
        replacedCard: MatchCard? = nil
    ) {
        self.id = id
        self.minute = minute
        self.teamName = teamName
        self.playerNumber = playerNumber
        self.type = type
        self.description = description
        self.overtimeSeconds = overtimeSeconds
        self.matchSeconds = matchSeconds
        self.recordedAt = recordedAt
        self.cardID = cardID
        self.replacedCard = replacedCard
    }
}

public extension MatchEvent {
    /// Recorded when the referee ends the match before time (abandoned match).
    static let matchEndedEarly = "MATCH ENDED EARLY"

    /// Match clock of the event: `MM:SS` when the second is known, otherwise the minute (`41'`).
    var clockLabel: String {
        guard let matchSeconds else { return "\(minute)'" }
        return String(format: "%02d:%02d", matchSeconds / 60, matchSeconds % 60)
    }

    /// `description` stays in English because it is synced between iPhone and Watch.
    /// This is the text shown on screen and in the shared match record, in the reader's language.
    var localizedDescription: String {
        switch type {
        case .yellowCard:
            if let playerNumber { return String(appLocalized: "Yellow Card (Sin-Bin) - #\(playerNumber)") }
            return String(appLocalized: "Yellow Card (Sin-Bin)")
        case .redCard:
            guard let playerNumber else { return String(appLocalized: "Red Card (Expulsion)") }
            switch (isTwentyMinuteRed, isSecondYellow) {
            case (true, true): return String(appLocalized: "20-Minute Red Card (Second Yellow) - #\(playerNumber)")
            case (true, false): return String(appLocalized: "20-Minute Red Card - #\(playerNumber)")
            case (false, true): return String(appLocalized: "Red Card (Second Yellow) - #\(playerNumber)")
            case (false, false): return String(appLocalized: "Red Card (Expulsion) - #\(playerNumber)")
            }
        case .tryScore, .sub:
            switch description {
            case "Try scored (+5)": return String(appLocalized: "Try scored (+5)")
            case "Conversion (+2)": return String(appLocalized: "Conversion (+2)")
            case "Penalty goal (+3)": return String(appLocalized: "Penalty goal (+3)")
            case "Drop goal (+3)": return String(appLocalized: "Drop goal (+3)")
            case "Penalty try (+7)": return String(appLocalized: "Penalty try (+7)")
            case "HALF-TIME WHISTLE": return String(appLocalized: "HALF-TIME WHISTLE")
            case "FULL-TIME WHISTLE": return String(appLocalized: "FULL-TIME WHISTLE")
            case Self.matchEndedEarly: return String(appLocalized: "MATCH ENDED EARLY")
            case "Won the toss · kicks off": return String(appLocalized: "Won the toss · kicks off")
            case "Won the toss · chose an end": return String(appLocalized: "Won the toss · chose an end")
            default: return InjuryTimer.localizedDescription(of: description) ?? description
            }
        }
    }
}
