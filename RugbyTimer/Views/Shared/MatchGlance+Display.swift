import SwiftUI

/// How the Watch complication and the iPhone Live Activity draw a glance.
extension MatchGlance {
    /// Green, yellow or red for the clock; amber for the half-time break.
    func tint(at date: Date) -> Color {
        if isAtBreak { return .sinBinAmber }
        switch zone(at: date) {
        case .normal: return .pitchEmerald
        case .closing: return .cardYellow
        case .timeUp: return .expulsionRed
        }
    }

    /// The clock as live text: the system counts it down (and up in overtime) without the app running.
    func clockText(at date: Date) -> Text {
        if let breakEnd = breakEndsAt {
            return breakEnd > date ? Text(breakEnd, style: .timer) : Text(verbatim: Self.format(0))
        }
        if let end = clockEndsAt {
            return date < end ? Text(end, style: .timer) : Text("+\(Text(end, style: .timer))") // l10n-ignore: sign only
        }
        return Text(verbatim: (clockSeconds < 0 ? "+" : "") + Self.format(abs(clockSeconds)))
    }

    static func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
