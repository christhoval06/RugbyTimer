import Foundation

/// Builds the plain-text match record (bitácora) the referee can share after full time.
public enum MatchRecordFormatter {
    public static func record(
        homeTeam: String,
        awayTeam: String,
        homeScore: Int,
        awayScore: Int,
        halfDurationSeconds: Int,
        events: [MatchEvent],
        date: Date = Date()
    ) -> String {
        var lines: [String] = [
            String(localized: "RUGBY TIMER · MATCH RECORD"),
            date.formatted(date: .long, time: .shortened),
            "",
            "\(homeTeam) \(homeScore) – \(awayScore) \(awayTeam)",
            String(localized: "FULL TIME · 2 × \(halfDurationSeconds / 60) min"),
            "",
            String(localized: "TIMELINE")
        ]

        if events.isEmpty {
            lines.append(String(localized: "No recorded events."))
        } else {
            for event in events {
                let minute = "\(event.minute)'".padding(toLength: 5, withPad: " ", startingAt: 0)
                let player = event.playerNumber.map { " #\($0)" } ?? ""
                let team = event.teamName == "OFFICIAL" ? "" : "\(event.teamName)\(player) · "
                lines.append("\(minute)\(team)\(event.localizedDescription)")
            }
        }

        let yellow = events.filter { $0.type == .yellowCard }
        let red = events.filter { $0.type == .redCard }
        if !yellow.isEmpty || !red.isEmpty {
            lines += ["", String(localized: "DISCIPLINE"), String(localized: "Yellow cards: \(yellow.count) · Red cards: \(red.count)")]
        }

        return lines.joined(separator: "\n")
    }
}
