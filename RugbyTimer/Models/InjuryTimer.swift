//
//  InjuryTimer.swift
//  RugbyTimer
//

import Foundation

/// Why a player is temporarily off: a head injury assessment or a blood injury.
nonisolated public enum InjuryKind: String, Codable, CaseIterable {
    case hia
    case blood

    /// HIA off-field assessment: 12 minutes. Blood replacement: 15 minutes.
    public var durationSeconds: Int { self == .hia ? 720 : 900 }

    /// English event text; synced, and translated by `InjuryTimer.localizedDescription`.
    var eventName: String { self == .hia ? "HIA" : "Blood replacement" } // l10n-ignore: synced English
    var shortName: String { self == .hia ? "HIA" : "Blood" } // l10n-ignore: synced English
}

/// How an injury timer ends: the player comes back on, or the replacement becomes permanent.
nonisolated public enum InjuryOutcome: String, Codable {
    case returned
    case replaced
}

/// A temporary replacement counted in real time, so it keeps running through stoppages and half-time.
nonisolated public struct InjuryTimer: Identifiable, Equatable, Codable {
    public let id: UUID
    public let teamName: String
    public let playerNumber: Int
    public let kind: InjuryKind
    public let startedAt: Date

    public init(id: UUID = UUID(), teamName: String, playerNumber: Int, kind: InjuryKind, startedAt: Date = Date()) {
        self.id = id
        self.teamName = teamName
        self.playerNumber = playerNumber
        self.kind = kind
        self.startedAt = startedAt
    }

    public var endsAt: Date { startedAt.addingTimeInterval(TimeInterval(kind.durationSeconds)) }

    /// Seconds left at `now`; negative once the time is up.
    public func remainingSeconds(at now: Date = Date()) -> Int {
        Int(endsAt.timeIntervalSince(now).rounded(.up))
    }

    /// Event text for the match record, in English (it's synced): "HIA - #8", "Blood · returned - #8".
    static func eventDescription(_ kind: InjuryKind, outcome: InjuryOutcome? = nil, number: Int) -> String {
        guard let outcome else { return "\(kind.eventName) - #\(number)" }
        return "\(kind.shortName) · \(outcome.rawValue) - #\(number)"
    }

    /// Translates an injury event description; nil when the text isn't one.
    static func localizedDescription(of description: String) -> String? {
        guard let match = description.wholeMatch(of: /(HIA|Blood replacement|Blood)( · (returned|replaced))? - #(\d+)/),
              let number = Int(match.4) else { return nil }
        let isHIA = match.1 == "HIA"
        switch match.3 {
        case "returned"?: return isHIA ? String(appLocalized: "HIA · returned - #\(number)")
                                       : String(appLocalized: "Blood · returned - #\(number)")
        case "replaced"?: return isHIA ? String(appLocalized: "HIA · replaced - #\(number)")
                                       : String(appLocalized: "Blood · replaced - #\(number)")
        default: return isHIA ? String(appLocalized: "HIA - #\(number)")
                              : String(appLocalized: "Blood replacement - #\(number)")
        }
    }
}
