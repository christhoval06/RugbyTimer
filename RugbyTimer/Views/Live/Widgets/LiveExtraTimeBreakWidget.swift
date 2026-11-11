import SwiftUI

/// iPhone-only mode, extra-time break: kick off the next period, or end the match as a
/// draw (no more extra time, e.g. for a kicking competition).
struct LiveExtraTimeBreakWidget: View {
    let nextPeriod: MatchPeriod?
    let onKickOff: () -> Void
    let onEndAsDraw: () -> Void

    @State private var isConfirmingDraw = false

    var body: some View {
        VStack(spacing: 10) {
            switch nextPeriod {
            case .extraTimeFirstHalf?:
                LiveKickOffButtonWidget(title: "KICK OFF ET1", subtitle: "START EXTRA TIME",
                                        identifier: "kickOffExtraTime", action: onKickOff)
            case .extraTimeSecondHalf?:
                LiveKickOffButtonWidget(title: "KICK OFF ET2", subtitle: "START THE SECOND HALF OF EXTRA TIME",
                                        identifier: "kickOffExtraTime", action: onKickOff)
            default:
                LiveKickOffButtonWidget(title: "SUDDEN DEATH", subtitle: "FIRST SCORE WINS",
                                        identifier: "kickOffExtraTime", action: onKickOff)
            }
            LiveControlTileWidget(symbol: "equal.circle", title: "END AS A DRAW", tint: Color.iceTitanium) {
                isConfirmingDraw = true
            }
        }
        .confirmationDialog("END AS A DRAW", isPresented: $isConfirmingDraw, titleVisibility: .visible) {
            Button("End the match", role: .destructive, action: onEndAsDraw)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("No more extra time. The match ends level, ready for a kicking competition.")
        }
    }
}

#Preview {
    LiveExtraTimeBreakWidget(nextPeriod: .extraTimeFirstHalf, onKickOff: {}, onEndAsDraw: {})
        .padding()
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
