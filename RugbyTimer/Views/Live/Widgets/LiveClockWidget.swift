import SwiftUI

struct LiveClockWidget: View {
    let matchPeriod: MatchPeriod
    let timeRemaining: Int
    let totalDuration: Int
    let isRunning: Bool
    var overtimeSeconds: Int = 0
    var isPhoneHosted = false
    /// Shrinks the ring so the clock fits short screens (iPhone landscape).
    var ringScale: CGFloat = 1
    var showsHeading = true

    var body: some View {
        VStack(spacing: 12) {
            if showsHeading {
                SetupSectionHeadingWidget(number: "01", title: "MATCH CLOCK", detail: "\(totalDuration / 60) MIN PER HALF")
            }
            Group {
                switch matchPeriod {
                case .firstHalf, .secondHalf:
                    VStack(spacing: 8) {
                        LiveTimerRingWidget(
                            timeRemaining: timeRemaining,
                            totalDuration: totalDuration,
                            isRunning: isRunning,
                            overtimeSeconds: overtimeSeconds,
                            periodLabel: matchPeriod == .firstHalf ? "FIRST HALF · H1" : "SECOND HALF · H2"
                        )
                        .scaleEffect(ringScale)
                        .frame(width: 260 * ringScale, height: 260 * ringScale)
                        .padding(.top, 16 * ringScale)
                        LiveClockStatsWidget(timeRemaining: timeRemaining, totalDuration: totalDuration,
                                             overtimeSeconds: overtimeSeconds)
                    }
                case .preMatch:
                    LiveClockMessageWidget(symbol: isPhoneHosted ? "sportscourt" : "applewatch", title: "READY FOR KICKOFF",
                                           message: isPhoneHosted ? "Tap Kick Off to start the clock" : "Start the match on Apple Watch",
                                           tint: Color.pitchEmerald)
                case .halfTime:
                    LiveClockMessageWidget(symbol: "pause.circle", title: "HALF-TIME BREAK",
                                           message: isPhoneHosted ? "Tap Kick Off H2 when the teams are ready" : "Start the second half on Apple Watch",
                                           tint: Color.sinBinAmber)
                case .fullTime:
                    LiveClockMessageWidget(symbol: "flag.checkered", title: "FULL TIME",
                                           message: "The match has finished", tint: Color.iceTitanium)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }
}
