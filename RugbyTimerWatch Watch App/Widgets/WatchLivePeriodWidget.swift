import SwiftUI

struct WatchLivePeriodWidget: View {
    let matchPeriod: MatchPeriod

    private var tint: Color {
        switch matchPeriod {
        case .halfTime: .sinBinAmber
        case .fullTime: .outline
        default: .pitchEmerald
        }
    }

    private var label: LocalizedStringKey {
        switch matchPeriod {
        case .preMatch: "PRE-MATCH"
        case .firstHalf: "1ST HALF"
        case .halfTime: "HALF-TIME"
        case .secondHalf: "2ND HALF"
        case .fullTime: "FULL TIME"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(tint).frame(width: 3, height: 3)
            Text(label)
                .font(.system(size: 7, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(tint)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(matchPeriod.title))
    }
}
