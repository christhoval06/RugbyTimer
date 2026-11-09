import SwiftUI

/// iPhone landscape layout: the match clock pinned on the left, details and controls on the right.
/// The clock column receives its available height so it can size itself to fit without scrolling.
struct LiveLandscapeLayoutWidget<Clock: View, Details: View, Footer: View>: View {
    private let clock: (CGFloat) -> Clock
    private let details: Details
    private let footer: Footer

    init(
        @ViewBuilder clock: @escaping (CGFloat) -> Clock,
        @ViewBuilder details: () -> Details,
        @ViewBuilder footer: () -> Footer
    ) {
        self.clock = clock
        self.details = details()
        self.footer = footer()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            GeometryReader { proxy in
                clock(proxy.size.height - 32)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Color.armorBorder.frame(width: 1)

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) { details }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                .scrollBounceBehavior(.basedOnSize)
                .clipped()
                footer
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Landscape layout", traits: .landscapeLeft) {
    LiveLandscapeLayoutWidget { height in
        LiveClockWidget(matchPeriod: .firstHalf, timeRemaining: 1834, totalDuration: 2400, isRunning: true,
                        ringScale: min(1, (height - 100) / 276), showsHeading: false)
    } details: {
        LivePeriodStatusWidget(matchPeriod: .firstHalf, isRunning: true)
        LiveScoreboardWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", homeScore: 12, awayScore: 7)
        LiveSinBinWidget(cards: [MatchCard(teamName: "City Lions", playerNumber: 6, type: .yellow, durationSeconds: 380)])
    } footer: {
        Text("Footer").foregroundStyle(Color.outline).padding()
    }
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
