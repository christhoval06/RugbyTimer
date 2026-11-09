//
//  MatchPeriod.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation

public enum MatchPeriod: String, Equatable, Codable {
    case preMatch = "PRE-MATCH"
    case firstHalf = "FIRST HALF (H1)"
    case halfTime = "HALF-TIME BREAK"
    case secondHalf = "SECOND HALF (H2)"
    case fullTime = "FULL TIME"
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
        }
    }
}
