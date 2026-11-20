import SwiftUI

struct WatchCenterPagesWidget: View {
    enum Page: Hashable { case timers, details, activeTimers, results }

    @Binding var selection: Page
    let clock: WatchClockPageView
    let details: WatchClockDetailsWidget?
    let activeTimers: WatchActiveTimersWidget
    let result: WatchResultPageView
    let isFullTime: Bool

    var body: some View {
        TabView(selection: $selection) {
            if !isFullTime {
                clock.tag(Page.timers)
                if let details {
                    details.tag(Page.details)
                }
                activeTimers.tag(Page.activeTimers)
            }
            result.tag(Page.results)
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    let timer = MatchTimerService(initialSeconds: 2180)
    let summary = WatchMatchSummary(
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        homeScore: 12, awayScore: 7, matchPeriod: .firstHalf,
        activeCards: WatchMatchSummary.preview.activeCards, matchEvents: []
    )
    WatchCenterPagesWidget(
        selection: .constant(.activeTimers),
        clock: WatchClockPageView(timerService: timer, summary: summary,
                                  totalDuration: 2400, onStartSecondHalf: {}, onEndPeriod: {}, includesDetails: false),
        details: WatchClockDetailsWidget(timerService: timer, totalDuration: 2400, matchPeriod: .firstHalf,
                                         onEndMatch: {}),
        activeTimers: WatchActiveTimersWidget(summary: summary, actions: .preview),
        result: WatchResultPageView(summary: summary), isFullTime: false
    )
}
