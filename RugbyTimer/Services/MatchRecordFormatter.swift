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
            events.contains { $0.description == ExtraTimeWhistle.halfTime || $0.description == ExtraTimeWhistle.fullTime
                || $0.description == ExtraTimeWhistle.suddenDeath }
                ? String(appLocalized: "FULL TIME · 2 × \(halfDurationSeconds / 60) min + extra time")
                : String(appLocalized: "FULL TIME · 2 × \(halfDurationSeconds / 60) min"),
            "",
            String(appLocalized: "TIMELINE")
        ]

        // Penalties and free kicks are summed below, not listed one by one.
        let timeline = events.filter { Infringement.of($0) == nil }
        if timeline.isEmpty {
            lines.append(String(appLocalized: "No recorded events."))
        } else {
            for event in timeline {
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

        lines += penaltyLines(events: events, teams: [homeTeam, awayTeam])
        return lines.joined(separator: "\n")
    }

    /// "PENALTIES CONCEDED" with each team's penalties (by half) and free kicks; empty when none.
    private static func penaltyLines(events: [MatchEvent], teams: [String]) -> [String] {
        guard events.contains(where: { Infringement.of($0) != nil }) else { return [] }
        var lines = ["", String(appLocalized: "PENALTIES CONCEDED")]
        for team in teams {
            let total = InfringementCount.count(in: events, team: team)
            let halves = InfringementCount.byHalf(in: events, team: team)
            lines.append(String(appLocalized: "\(team): penalties \(total.penalties) (H1 \(halves.firstHalf.penalties), H2 \(halves.secondHalf.penalties)) · free kicks \(total.freeKicks)"))
        }
        return lines
    }
}
