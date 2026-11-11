import SwiftUI
import WidgetKit

/// One moment of the complication: the saved snapshot read at `date`.
struct MatchClockEntry: TimelineEntry {
    let date: Date
    let snapshot: ComplicationSnapshot

    /// Seconds on the clock at `date`; negative in overtime.
    var clockSeconds: Int {
        guard let end = snapshot.clockEndsAt else { return snapshot.clockSeconds }
        return Int(end.timeIntervalSince(date).rounded(.up))
    }

    var zone: ClockZone {
        ClockZone.zone(timeRemaining: max(0, clockSeconds), totalDuration: snapshot.periodSeconds,
                       overtimeSeconds: max(0, -clockSeconds))
    }

    var isAtBreak: Bool { snapshot.breakEndsAt != nil }

    /// Green, yellow or red for the clock; amber for the half-time break.
    var tint: Color {
        if isAtBreak { return .sinBinAmber }
        switch zone {
        case .normal: return .pitchEmerald
        case .closing: return .cardYellow
        case .timeUp: return .expulsionRed
        }
    }

    var progress: Double {
        ClockZone.progress(timeRemaining: max(0, clockSeconds), totalDuration: snapshot.periodSeconds,
                           overtimeSeconds: max(0, -clockSeconds))
    }

    /// "12–7"
    var score: String { "\(snapshot.homeScore)–\(snapshot.awayScore)" } // l10n-ignore: numbers only

    /// The sin-bin still counting down at `date`, if any.
    var runningSinBinEndsAt: Date? {
        guard let end = snapshot.nextSinBinEndsAt, end > date else { return nil }
        return end
    }
}
