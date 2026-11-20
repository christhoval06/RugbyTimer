import SwiftUI

struct WatchTeamMatchPageWidget<Content: View>: View {
    let name: String
    let score: Int
    let tint: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.system(size: 18, weight: .black).width(.condensed))
                        .foregroundStyle(Color.iceTitanium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    Text(score, format: .number)
                        .font(.system(size: 27, weight: .heavy, design: .monospaced))
                        .foregroundStyle(tint)
                }
                content()
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }
}

#Preview {
    WatchTeamMatchPageWidget(name: "Rangers RFC", score: 12, tint: .pitchEmerald) {
        WatchScorePageView(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", homeScore: 12,
                           awayScore: 7, fixedTeam: "Rangers RFC") { _, _, _, _ in }
    }
}
