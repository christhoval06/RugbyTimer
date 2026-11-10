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
    
    public init(
        id: UUID = UUID(),
        minute: Int,
        teamName: String,
        playerNumber: Int? = nil,
        type: MatchEventType,
        description: String
    ) {
        self.id = id
        self.minute = minute
        self.teamName = teamName
        self.playerNumber = playerNumber
        self.type = type
        self.description = description
    }
}

public extension MatchEvent {
    /// `description` stays in English because it is synced between iPhone and Watch.
    /// This is the text shown on screen and in the shared match record, in the reader's language.
    var localizedDescription: String {
        switch type {
        case .yellowCard:
            if let playerNumber { return String(localized: "Yellow Card (Sin-Bin) - #\(playerNumber)") }
            return String(localized: "Yellow Card (Sin-Bin)")
        case .redCard:
            if let playerNumber { return String(localized: "Red Card (Expulsion) - #\(playerNumber)") }
            return String(localized: "Red Card (Expulsion)")
        case .tryScore, .sub:
            switch description {
            case "Try scored (+5)": return String(localized: "Try scored (+5)")
            case "Conversion (+2)": return String(localized: "Conversion (+2)")
            case "Penalty goal (+3)": return String(localized: "Penalty goal (+3)")
            case "Drop goal (+3)": return String(localized: "Drop goal (+3)")
            case "HALF-TIME WHISTLE": return String(localized: "HALF-TIME WHISTLE")
            case "FULL-TIME WHISTLE": return String(localized: "FULL-TIME WHISTLE")
            case "Won the toss · kicks off": return String(localized: "Won the toss · kicks off")
            case "Won the toss · chose an end": return String(localized: "Won the toss · chose an end")
            default: return description
            }
        }
    }
}
