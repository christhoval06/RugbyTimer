import SwiftUI

struct LivePeriodStatusWidget: View {
    let matchPeriod: MatchPeriod
    let isRunning: Bool

    private var tint: Color {
        switch matchPeriod {
        case .firstHalf, .secondHalf: isRunning ? Color.pitchEmerald : Color.sinBinAmber
        case .halfTime: Color.sinBinAmber
        case .preMatch, .fullTime: Color.outline
        }
    }

    private var status: LocalizedStringKey {
        switch matchPeriod {
        case .preMatch: "WAITING FOR KICKOFF"
        case .firstHalf, .secondHalf: isRunning ? "CLOCK RUNNING" : "CLOCK PAUSED"
        case .halfTime: "TEAMS IN THE SHED"
        case .fullTime: "MATCH COMPLETE"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 22))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Circle().fill(tint).frame(width: 5, height: 5)
                    Text(status)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(tint)
                }
                Text(matchPeriod.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.iceTitanium)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }
}
