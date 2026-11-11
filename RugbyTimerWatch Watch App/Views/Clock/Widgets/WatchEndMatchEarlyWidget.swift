import SwiftUI

/// Lets the referee end the match before time, e.g. when it is abandoned for weather,
/// injury or the pitch. It asks first, because the match cannot be resumed afterwards.
struct WatchEndMatchEarlyWidget: View {
    @ObservedObject var timerService: MatchTimerService
    let matchPeriod: MatchPeriod
    let onEndMatch: () -> Void

    @State private var isConfirming = false

    /// Once a match-ending period is past time, the regular END button is already on screen.
    private var isHidden: Bool {
        timerService.isInOvertime && [.secondHalf, .extraTimeSecondHalf, .suddenDeath].contains(matchPeriod)
    }

    var body: some View {
        if !isHidden {
            Button { isConfirming = true } label: {
                Label("END MATCH EARLY", systemImage: "xmark.octagon")
                    .font(.system(size: 11, weight: .heavy).width(.condensed))
                    .foregroundStyle(Color.expulsionRed)
                    .frame(maxWidth: .infinity, minHeight: 32)
                    .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.expulsionRed.opacity(0.6)))
            }
            .buttonStyle(WatchTapLockButtonStyle())
            .padding(.top, 6)
            .accessibilityHint("Ends the match before time, for example if it is abandoned")
            .confirmationDialog("End the match now?", isPresented: $isConfirming, titleVisibility: .visible) {
                Button("End match", role: .destructive, action: onEndMatch)
                Button("Keep playing", role: .cancel) {}
            } message: {
                Text("The clock stops and the current score becomes the final result.")
            }
        }
    }
}

#Preview("First half") {
    WatchEndMatchEarlyWidget(timerService: MatchTimerService(initialSeconds: 1200),
                             matchPeriod: .firstHalf, onEndMatch: {})
        .padding()
}
