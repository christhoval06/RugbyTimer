import SwiftUI
import WidgetKit

/// "▮ 2 · 6:52": players in the sin-bin and the countdown for the first one back.
struct MatchActivitySinBinRow: View {
    let glance: MatchGlance
    let date: Date

    var body: some View {
        if glance.sinBinCount > 0 {
            HStack(spacing: 4) {
                Image(systemName: "rectangle.portrait.fill")
                    .foregroundStyle(Color.cardYellow)
                Text(verbatim: "\(glance.sinBinCount)")
                if let end = glance.runningSinBinEndsAt(at: date) {
                    Text(verbatim: "·")
                    Text(end, style: .timer)
                        .monospacedDigit()
                }
                Spacer(minLength: 0)
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.outline)
        }
    }
}

#Preview(as: .content, using: MatchActivityAttributes(matchID: UUID())) {
    MatchActivityWidget()
} contentStates: {
    MatchGlance.samples()[1]
}
