import SwiftUI

/// Shown once the half's time is up: play continues until the ball is dead,
/// then the referee ends the period here.
struct WatchEndPeriodWidget: View {
    @ObservedObject var timerService: MatchTimerService
    let matchPeriod: MatchPeriod
    let onEndPeriod: () -> Void

    private var title: LocalizedStringKey { matchPeriod == .secondHalf ? "END MATCH" : "END HALF" }

    var body: some View {
        if timerService.isInOvertime {
            Button(action: onEndPeriod) {
                HStack(spacing: 6) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 22, height: 22)
                        .background(Color.iceTitanium.opacity(0.15), in: Circle())
                    Text(title)
                        .font(.system(size: 12, weight: .heavy).width(.condensed))
                    Spacer(minLength: 0)
                    Text("DEAD BALL")
                        .font(.system(size: 7, weight: .bold))
                        .tracking(0.6)
                        .opacity(0.8)
                }
                .padding(.horizontal, 10)
                .foregroundStyle(Color.iceTitanium)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(Color.expulsionRed, in: RoundedRectangle(cornerRadius: 11))
            }
            .buttonStyle(WatchTapLockButtonStyle())
            .accessibilityLabel(title)
            .accessibilityHint(matchPeriod == .secondHalf ? "Blows the whistle to end the match" : "Blows the whistle to end the half")
        }
    }
}
