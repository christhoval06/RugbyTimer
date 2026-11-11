import SwiftUI
import WidgetKit

/// A team's name over its score, aligned to its side of the banner.
struct MatchActivityTeamScore: View {
    let name: String
    let score: Int
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            Text(verbatim: name)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.outline)
                .lineLimit(1)
            Text(verbatim: "\(score)")
                .font(.system(size: 34, weight: .black).width(.condensed))
                .monospacedDigit()
                .foregroundStyle(Color.iceTitanium)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }
}

#Preview(as: .content, using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[0]
}
