import SwiftUI

/// The break before an extra-time period: the level score, the next period's kick-off,
/// and ending the match as a draw instead (for a kicking competition, say).
struct WatchExtraTimeBreakWidget: View {
    let homeScore: Int
    let awayScore: Int
    let nextPeriod: MatchPeriod?
    let onKickOff: () -> Void
    let onEndAsDraw: () -> Void

    @State private var isConfirmingDraw = false

    private var kickOffTitle: LocalizedStringKey {
        switch nextPeriod {
        case .extraTimeFirstHalf?: "KICK OFF ET1"
        case .extraTimeSecondHalf?: "KICK OFF ET2"
        default: "START SUDDEN DEATH"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("LEVEL")
                    .font(.system(size: 20, weight: .black).width(.condensed))
                    .foregroundStyle(Color.iceTitanium)
                Spacer(minLength: 4)
                Text(verbatim: "\(homeScore)–\(awayScore)")
                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.sinBinAmber)
                    .accessibilityLabel(Text("Score \(homeScore) to \(awayScore)"))
            }

            Button(action: onKickOff) {
                HStack(spacing: 6) {
                    Image(systemName: nextPeriod == .suddenDeath ? "bolt.fill" : "play.fill")
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 22, height: 22)
                        .background(Color.pitchVoid.opacity(0.12), in: Circle())
                    Text(kickOffTitle)
                        .font(.system(size: 12, weight: .heavy).width(.condensed))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .foregroundStyle(Color.pitchVoid)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(Color.sinBinAmber, in: RoundedRectangle(cornerRadius: 11))
            }
            .buttonStyle(WatchTapLockButtonStyle())
            .accessibilityLabel(kickOffTitle)

            Button { isConfirmingDraw = true } label: {
                Text("END AS A DRAW")
                    .font(.system(size: 11, weight: .heavy).width(.condensed))
                    .foregroundStyle(Color.iceTitanium)
                    .frame(maxWidth: .infinity, minHeight: 32)
                    .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
            }
            .buttonStyle(WatchTapLockButtonStyle())
            .confirmationDialog("END AS A DRAW", isPresented: $isConfirmingDraw, titleVisibility: .visible) {
                Button("End the match", role: .destructive, action: onEndAsDraw)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("No more extra time. The match ends level, ready for a kicking competition.")
            }
        }
    }
}

#Preview("Extra-time break") {
    WatchExtraTimeBreakWidget(homeScore: 17, awayScore: 17, nextPeriod: .extraTimeFirstHalf,
                              onKickOff: {}, onEndAsDraw: {})
        .padding()
}
