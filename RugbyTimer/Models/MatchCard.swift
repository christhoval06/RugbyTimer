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
    public private(set) var isExpired: Bool

    public init(id: UUID = UUID(), teamName: String, playerNumber: Int, type: CardType, durationSeconds: Int = 600) {
        self.id = id
        self.teamName = teamName
        self.playerNumber = playerNumber
        self.type = type
        self.remainingSeconds = durationSeconds
        self.isExpired = (durationSeconds <= 0) || (type == .red)
    }

    public mutating func tick(seconds: Int = 1) {
        guard !isExpired, type == .yellow, seconds > 0 else { return }
        remainingSeconds = max(0, remainingSeconds - seconds)
        if remainingSeconds <= 0 {
            isExpired = true
        }
    }
}
