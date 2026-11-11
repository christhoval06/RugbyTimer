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
                case .firstHalf, .secondHalf, .extraTimeFirstHalf, .extraTimeSecondHalf, .suddenDeath:
                    VStack(spacing: 8) {
                        LiveTimerRingWidget(
                            timeRemaining: timeRemaining,
                            totalDuration: totalDuration,
                            isRunning: isRunning,
                            overtimeSeconds: overtimeSeconds,
                            periodLabel: periodLabel
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
                case .extraTimeBreak:
                    LiveClockMessageWidget(symbol: "equal.circle", title: "EXTRA TIME",
                                           message: isPhoneHosted ? "Level at full time. Kick off extra time, or end as a draw"
                                                                  : "Level at full time. Start extra time on Apple Watch",
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

    private var periodLabel: LocalizedStringResource {
        switch matchPeriod {
        case .secondHalf: "SECOND HALF · H2"
        case .extraTimeFirstHalf: "EXTRA TIME · ET1"
        case .extraTimeSecondHalf: "EXTRA TIME · ET2"
        case .suddenDeath: "SUDDEN DEATH"
        default: "FIRST HALF · H1"
        }
    }
}
