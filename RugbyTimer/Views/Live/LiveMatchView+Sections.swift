import SwiftUI

/// Section builders shared by the portrait and landscape layouts.
extension LiveMatchView {
    var periodStatus: some View {
        LivePeriodStatusWidget(matchPeriod: matchPeriod, isRunning: timerService.isRunning)
    }

    func clock(ringScale: CGFloat = 1, showsHeading: Bool = true) -> some View {
        LiveClockWidget(
            matchPeriod: matchPeriod,
            timeRemaining: timerService.timeRemaining,
            totalDuration: totalDuration,
            isRunning: timerService.isRunning,
            overtimeSeconds: timerService.overtimeSeconds,
            isPhoneHosted: isPhoneHosted,
            ringScale: ringScale,
            showsHeading: showsHeading
        )
    }

    @ViewBuilder var matchDetails: some View {
        LiveScoreboardWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                             homeScore: homeScore, awayScore: awayScore)
        LiveScoringWidget(events: matchEvents, homeTeamName: homeTeamName)
        LiveSinBinWidget(cards: activeCards)
    }

    var footer: some View {
        LiveFooterWidget(
            matchPeriod: matchPeriod,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            matchRecord: matchRecord,
            onReturnToSetup: onReturnToSetup,
            isRunning: timerService.isRunning,
            phoneControls: phoneControls
        )
    }

    func matchRecord() -> String {
        MatchRecordFormatter.record(
            homeTeam: homeTeamName,
            awayTeam: awayTeamName,
            homeScore: homeScore,
            awayScore: awayScore,
            halfDurationSeconds: totalDuration,
            events: matchEvents
        )
    }
}
