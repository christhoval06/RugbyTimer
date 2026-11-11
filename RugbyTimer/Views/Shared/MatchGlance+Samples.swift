import Foundation

extension MatchGlance {
    /// Preview and gallery glances: a running half, a closing half with a sin-bin, overtime, the break.
    static func samples(now: Date = Date()) -> [MatchGlance] {
        var running = MatchGlance.idle
        running.homeTeamName = "Rangers RFC" // l10n-ignore: sample data
        running.awayTeamName = "City Lions" // l10n-ignore: sample data
        running.homeScore = 12
        running.awayScore = 7
        running.periodLabel = "H1" // l10n-ignore: sample data
        running.pausedLabel = "PAUSED" // l10n-ignore: sample data
        running.timeUpLabel = "TIME UP" // l10n-ignore: sample data
        running.periodSeconds = 2400
        running.isPlaying = true
        running.isMatchLive = true
        running.clockEndsAt = now.addingTimeInterval(1834)

        var closing = running
        closing.clockEndsAt = now.addingTimeInterval(204)
        closing.nextSinBinEndsAt = now.addingTimeInterval(412)
        closing.sinBinCount = 1

        var overtime = running
        overtime.clockEndsAt = now.addingTimeInterval(-37)

        var halfTime = running
        halfTime.periodLabel = "HT" // l10n-ignore: sample data
        halfTime.isPlaying = false
        halfTime.clockEndsAt = nil
        halfTime.breakEndsAt = now.addingTimeInterval(95)

        return [running, closing, overtime, halfTime]
    }
}
