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
            totalDuration: periodDuration ?? totalDuration,
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
        LiveSinBinWidget(cards: activeCards, injuries: injuryTimers, actions: offFieldActions)
        LivePenaltyCountWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName, events: matchEvents,
                               onConcede: isPlaying ? phoneControls?.onConcede : nil)
    }

    /// Landscape clock column at full time: the result and the record share button.
    var fullTimePanel: some View {
        VStack(spacing: 14) {
            LiveFinalResultWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                                  homeScore: homeScore, awayScore: awayScore)
            LiveShareRecordWidget(onShowRecord: showRecord)
        }
    }

    func showRecord() {
        shownRecord = MatchRecordSheetItem(text: matchRecord())
    }

    func footer(showsShareRecord: Bool = true) -> some View {
        LiveFooterWidget(
            matchPeriod: matchPeriod,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            onShowRecord: showRecord,
            onReturnToSetup: onReturnToSetup,
            isRunning: timerService.isRunning,
            phoneControls: phoneControls,
            showsShareRecord: showsShareRecord
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

    var recordSubject: String {
        String(appLocalized: "Match record: \(homeTeamName) vs \(awayTeamName)")
    }
}

/// The record text travels with the sheet's item, so the sheet can never open on stale (empty) text.
struct MatchRecordSheetItem: Identifiable {
    let id = UUID()
    let text: String
}
