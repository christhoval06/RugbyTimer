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
            String(appLocalized: "RUGBY TIMER · MATCH RECORD"),
            date.formatted(Date.FormatStyle(date: .long, time: .shortened).locale(AppLanguage.current.locale)),
            "",
            "\(homeTeam) \(homeScore) – \(awayScore) \(awayTeam)",
            String(appLocalized: "FULL TIME · 2 × \(halfDurationSeconds / 60) min"),
            "",
            String(appLocalized: "TIMELINE")
        ]

        if events.isEmpty {
            lines.append(String(appLocalized: "No recorded events."))
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
            lines += ["", String(appLocalized: "DISCIPLINE"), String(appLocalized: "Yellow cards: \(yellow.count) · Red cards: \(red.count)")]
        }

        return lines.joined(separator: "\n")
    }
}
