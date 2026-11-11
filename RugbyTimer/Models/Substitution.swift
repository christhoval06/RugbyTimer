//
//  Substitution.swift
//  RugbyTimer
//

import Foundation

/// Whether a match tracks substitutions, and how many each team may make.
/// Set in Match Setup (iPhone) or Quick Match (Watch); sent to the Watch with the setup.
nonisolated public struct SubstitutionRules: Codable, Equatable {
    /// Replacements per team: 8 for fifteens, 5 for sevens, 12 for some competitions, or no limit.
    public static let limitOptions = [8, 5, 12, unlimited]
    public static let unlimited = 0

    /// Off: no substitutions page on the Watch and no SUB button on iPhone.
    public var isEnabled = false
    /// Replacements each team may make; `unlimited` (0) for rolling substitutions.
    public var limit = 8

    public init(isEnabled: Bool = false, limit: Int = 8) {
        self.isEnabled = isEnabled
        self.limit = limit
    }

    public var hasLimit: Bool { limit != Self.unlimited }
}

/// A permanent substitution: one shirt number off, another on. It's a match-record entry for
/// the team, so it syncs, can be undone and is counted from the record.
nonisolated public struct Substitution: Equatable {
    public let off: Int
    public let on: Int

    /// English, like every synced description: "Substitution - #3 off, #18 on".
    var eventDescription: String { "Substitution - #\(off) off, #\(on) on" } // l10n-ignore: synced English

    var localizedDescription: String { String(appLocalized: "Substitution · #\(off) off, #\(on) on") }

    /// The substitution an entry records, if it records one.
    static func of(_ event: MatchEvent) -> Substitution? {
        guard event.type == .sub,
              let match = event.description.wholeMatch(of: /Substitution - #(\d+) off, #(\d+) on/),
              let off = Int(match.1), let on = Int(match.2) else { return nil }
        return Substitution(off: off, on: on)
    }

    /// Substitutions `team` has made so far.
    static func count(in events: [MatchEvent], team: String) -> Int {
        events.filter { $0.teamName == team && of($0) != nil }.count
    }
}

/// Why a substitution may be wrong. The referee can still record it: the call is theirs.
nonisolated public enum SubstitutionWarning: Equatable {
    case limitReached(Int)
    case offPlayerSanctioned(Int)
    case offPlayerAlreadyReplaced(Int)

    /// Checks a substitution against the record and the players off the field.
    static func check(_ sub: Substitution, team: String, rules: SubstitutionRules,
                      events: [MatchEvent], activeCards: [MatchCard]) -> SubstitutionWarning? {
        let made = Substitution.count(in: events, team: team)
        if rules.hasLimit && made >= rules.limit { return .limitReached(rules.limit) }
        let sentOff = events.contains { $0.teamName == team && $0.type == .redCard && $0.playerNumber == sub.off }
        let binned = activeCards.contains { $0.teamName == team && $0.playerNumber == sub.off }
        if sentOff || binned { return .offPlayerSanctioned(sub.off) }
        // Off earlier and not back on since: a second substitution for the same number is suspect.
        let teamSubs = events.filter { $0.teamName == team }.compactMap(Substitution.of)
        if let lastOff = teamSubs.lastIndex(where: { $0.off == sub.off }),
           !teamSubs[(lastOff + 1)...].contains(where: { $0.on == sub.off }) {
            return .offPlayerAlreadyReplaced(sub.off)
        }
        return nil
    }

    public var message: String {
        switch self {
        case .limitReached(let limit):
            String(appLocalized: "This team has already made \(limit) substitutions.")
        case .offPlayerSanctioned(let number):
            String(appLocalized: "#\(number) has a card. A carded player can't be replaced.")
        case .offPlayerAlreadyReplaced(let number):
            String(appLocalized: "#\(number) has already been replaced.")
        }
    }
}
