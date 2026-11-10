//
//  MatchEvent.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation

public enum MatchEventType: Equatable, Codable {
    case tryScore(points: Int) // +5 for try, +2 for conversion, +3 for penalty/drop goal
    case yellowCard
    case redCard
    case sub
}

public struct MatchEvent: Identifiable, Equatable, Codable {
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

    public init(
        id: UUID = UUID(),
        minute: Int,
        teamName: String,
        playerNumber: Int? = nil,
        type: MatchEventType,
        description: String,
        overtimeSeconds: Int? = nil
    ) {
        self.id = id
        self.minute = minute
        self.teamName = teamName
        self.playerNumber = playerNumber
        self.type = type
        self.description = description
        self.overtimeSeconds = overtimeSeconds
    }
}

public extension MatchEvent {
    /// Recorded when the referee ends the match before time (abandoned match).
    static let matchEndedEarly = "MATCH ENDED EARLY"

    /// `description` stays in English because it is synced between iPhone and Watch.
    /// This is the text shown on screen and in the shared match record, in the reader's language.
    var localizedDescription: String {
        switch type {
        case .yellowCard:
            if let playerNumber { return String(appLocalized: "Yellow Card (Sin-Bin) - #\(playerNumber)") }
            return String(appLocalized: "Yellow Card (Sin-Bin)")
        case .redCard:
            if let playerNumber { return String(appLocalized: "Red Card (Expulsion) - #\(playerNumber)") }
            return String(appLocalized: "Red Card (Expulsion)")
        case .tryScore, .sub:
            switch description {
            case "Try scored (+5)": return String(appLocalized: "Try scored (+5)")
            case "Conversion (+2)": return String(appLocalized: "Conversion (+2)")
            case "Penalty goal (+3)": return String(appLocalized: "Penalty goal (+3)")
            case "Drop goal (+3)": return String(appLocalized: "Drop goal (+3)")
            case "HALF-TIME WHISTLE": return String(appLocalized: "HALF-TIME WHISTLE")
            case "FULL-TIME WHISTLE": return String(appLocalized: "FULL-TIME WHISTLE")
            case Self.matchEndedEarly: return String(appLocalized: "MATCH ENDED EARLY")
            case "Won the toss · kicks off": return String(appLocalized: "Won the toss · kicks off")
            case "Won the toss · chose an end": return String(appLocalized: "Won the toss · chose an end")
            default: return description
            }
        }
    }
}
