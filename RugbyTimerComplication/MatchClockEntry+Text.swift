import SwiftUI

extension MatchClockEntry {
    /// The clock as live text: WidgetKit counts it down (and up in overtime) without the app running.
    var clockText: Text {
        if let breakEnd = snapshot.breakEndsAt {
            return breakEnd > date ? Text(breakEnd, style: .timer) : Text(Self.format(0))
        }
        if let end = snapshot.clockEndsAt {
            return date < end ? Text(end, style: .timer) : Text("+\(Text(end, style: .timer))") // l10n-ignore: sign only
        }
        let seconds = snapshot.clockSeconds
        return Text(verbatim: (seconds < 0 ? "+" : "") + Self.format(abs(seconds)))
    }

    /// "H1", "H1 · PAUSED", "H2 · TIME UP".
    var statusLabel: String {
        guard snapshot.isPlaying else { return snapshot.periodLabel }
        if zone == .timeUp { return "\(snapshot.periodLabel) · \(snapshot.timeUpLabel)" } // l10n-ignore: joins translated labels
        if !snapshot.isRunning { return "\(snapshot.periodLabel) · \(snapshot.pausedLabel)" } // l10n-ignore: joins translated labels
        return snapshot.periodLabel
    }

    /// Clock or break countdown on screen; otherwise (ready, full time) the score takes its place.
    var showsClock: Bool { snapshot.isPlaying || isAtBreak }

    var homeCode: String { ComplicationSnapshot.code(for: snapshot.homeTeamName) }
    var awayCode: String { ComplicationSnapshot.code(for: snapshot.awayTeamName) }

    static func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
