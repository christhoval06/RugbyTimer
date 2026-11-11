//
//  ExtraTimeFormat.swift
//  RugbyTimer
//

import Foundation

/// What happens when a knockout match is level at full time. Competitions decide this,
/// so it's a match setting. The referee can always end the match as a draw instead
/// (for example, to go to a kicking competition).
nonisolated public enum ExtraTimeFormat: String, Codable, CaseIterable {
    case off
    /// Fifteens: two halves of 10 minutes, then 10-minute sudden-death periods if still level.
    case twoHalves
    /// Sevens: 5-minute sudden-death periods until someone scores.
    case suddenDeath

    /// Length of each extra-time half or sudden-death period.
    public var periodSeconds: Int { self == .suddenDeath ? 300 : 600 }
}

/// Whistles that end extra-time periods. English, like every synced description.
nonisolated public enum ExtraTimeWhistle {
    public static let halfTime = "ET HALF-TIME WHISTLE" // l10n-ignore: synced English
    public static let fullTime = "ET FULL-TIME WHISTLE" // l10n-ignore: synced English
    public static let suddenDeath = "SUDDEN DEATH WHISTLE" // l10n-ignore: synced English
}
