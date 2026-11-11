import SwiftUI

struct WatchLivePeriodWidget: View {
    let matchPeriod: MatchPeriod

    private var tint: Color {
        switch matchPeriod {
        case .halfTime, .extraTimeBreak: .sinBinAmber
        case .fullTime: .outline
        case .suddenDeath: .expulsionRed
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
        case .extraTimeBreak: "EXTRA TIME"
        case .extraTimeFirstHalf: "EXTRA TIME · ET1"
        case .extraTimeSecondHalf: "EXTRA TIME · ET2"
        case .suddenDeath: "SUDDEN DEATH"
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
