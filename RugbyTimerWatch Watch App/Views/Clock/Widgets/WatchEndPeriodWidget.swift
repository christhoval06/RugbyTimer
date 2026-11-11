import SwiftUI

/// Shown once the period's time is up: play continues until the ball is dead, then the
/// referee ends the period here. In sudden death it shows as soon as a team scores.
struct WatchEndPeriodWidget: View {
    @ObservedObject var timerService: MatchTimerService
    let matchPeriod: MatchPeriod
    /// Sudden death: a team has scored, so the match is won now.
    var hasWinner = false
    let onEndPeriod: () -> Void

    private var title: LocalizedStringKey {
        switch matchPeriod {
        case .secondHalf: "END MATCH"
        case .extraTimeSecondHalf: "END EXTRA TIME"
        case .suddenDeath: hasWinner ? "END MATCH · WON" : "END PERIOD"
        default: "END HALF"
        }
    }

    var body: some View {
        if timerService.isInOvertime || hasWinner {
            Button(action: onEndPeriod) {
                HStack(spacing: 6) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 22, height: 22)
                        .background(Color.iceTitanium.opacity(0.15), in: Circle())
                    Text(title)
                        .font(.system(size: 12, weight: .heavy).width(.condensed))
                    Spacer(minLength: 0)
                    Text(hasWinner ? "FIRST SCORE" : "DEAD BALL")
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
            .accessibilityHint(matchPeriod == .firstHalf || matchPeriod == .extraTimeFirstHalf
                ? "Blows the whistle to end the half" : "Blows the whistle to end the period")
        }
    }
}
