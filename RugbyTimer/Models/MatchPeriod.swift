//
//  MatchPeriod.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation

nonisolated public enum MatchPeriod: String, Equatable, Codable {
    case preMatch = "PRE-MATCH"
    case firstHalf = "FIRST HALF (H1)"
    case halfTime = "HALF-TIME BREAK"
    case secondHalf = "SECOND HALF (H2)"
    case fullTime = "FULL TIME"
    // Extra time (knockout matches level at full time; see `ExtraTimeFormat`).
    case extraTimeBreak = "EXTRA-TIME BREAK"
    case extraTimeFirstHalf = "EXTRA TIME (ET1)"
    case extraTimeSecondHalf = "EXTRA TIME (ET2)"
    case suddenDeath = "SUDDEN DEATH"
}

public extension MatchPeriod {
    /// What people read. `rawValue` stays English because it is synced to the Watch.
    var title: LocalizedStringResource {
        switch self {
        case .preMatch: "PRE-MATCH"
        case .firstHalf: "FIRST HALF (H1)"
        case .halfTime: "HALF-TIME BREAK"
        case .secondHalf: "SECOND HALF (H2)"
        case .fullTime: "FULL TIME"
        case .extraTimeBreak: "EXTRA-TIME BREAK"
        case .extraTimeFirstHalf: "EXTRA TIME (ET1)"
        case .extraTimeSecondHalf: "EXTRA TIME (ET2)"
        case .suddenDeath: "SUDDEN DEATH"
        }
    }

    /// The clock is running a period: either half, an extra-time half or sudden death.
    var isPlaying: Bool {
        switch self {
        case .firstHalf, .secondHalf, .extraTimeFirstHalf, .extraTimeSecondHalf, .suddenDeath: true
        case .preMatch, .halfTime, .fullTime, .extraTimeBreak: false
        }
    }

    /// Between periods, with the match still to finish.
    var isBreak: Bool { self == .halfTime || self == .extraTimeBreak }

    /// A period played after the 80 minutes (or the break before one).
    var isExtraTime: Bool {
        self == .extraTimeBreak || self == .extraTimeFirstHalf || self == .extraTimeSecondHalf || self == .suddenDeath
    }
}
