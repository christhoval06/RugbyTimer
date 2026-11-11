//
//  Card.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation

public enum CardType: String, Equatable, Codable {
    case yellow
    case red
}

public struct MatchCard: Identifiable, Equatable, Codable {
    public let id: UUID
    public let teamName: String
    public let playerNumber: Int
    public let type: CardType
    public private(set) var remainingSeconds: Int
    /// Yellow: the player can return. 20-minute red: a replacement can come on. Full red: always.
    public private(set) var isExpired: Bool
    /// A 20-minute red card: the player is sent off, and a replacement can come on after 20 minutes.
    /// Optional so cards from older versions keep decoding (as full red cards).
    public let isTwentyMinuteRed: Bool?

    /// How long a team plays a player short after a 20-minute red card.
    public static let twentyMinuteRedSeconds = 1200

    public init(id: UUID = UUID(), teamName: String, playerNumber: Int, type: CardType, durationSeconds: Int = 600,
                twentyMinuteRed: Bool = false) {
        self.id = id
        self.teamName = teamName
        self.playerNumber = playerNumber
        self.type = type
        let isTimedRed = type == .red && twentyMinuteRed
        self.isTwentyMinuteRed = isTimedRed ? true : nil
        self.remainingSeconds = isTimedRed ? Self.twentyMinuteRedSeconds : durationSeconds
        self.isExpired = isTimedRed ? false : (durationSeconds <= 0) || (type == .red)
    }

    /// Yellow cards and 20-minute reds count down with the match clock.
    public var countsDown: Bool { type == .yellow || isTwentyMinuteRed == true }

    public mutating func tick(seconds: Int = 1) {
        guard !isExpired, countsDown, seconds > 0 else { return }
        remainingSeconds = max(0, remainingSeconds - seconds)
        if remainingSeconds <= 0 {
            isExpired = true
        }
    }
}
