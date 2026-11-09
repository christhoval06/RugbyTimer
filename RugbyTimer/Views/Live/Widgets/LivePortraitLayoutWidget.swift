import SwiftUI

/// Portrait layout: one scrolling column of match sections above a pinned footer.
struct LivePortraitLayoutWidget<Content: View, Footer: View>: View {
    private let content: Content
    private let footer: Footer

    init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) { content }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
            }
            .clipped()
            footer
        }
    }
}

#Preview("Portrait layout") {
    LivePortraitLayoutWidget {
        LiveHeaderWidget(isPlaying: true)
        LivePeriodStatusWidget(matchPeriod: .firstHalf, isRunning: true)
        LiveScoreboardWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", homeScore: 12, awayScore: 7)
    } footer: {
        Text("Footer").foregroundStyle(Color.outline).padding()
    }
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
