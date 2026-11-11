import SwiftUI

struct WatchLiveClockWidget: View {
    @ObservedObject var timerService: MatchTimerService
    let totalDuration: Int
    let matchPeriod: MatchPeriod

    var body: some View {
        Button(action: toggleClock) {
            WatchTimerDialWidget(
                timeRemaining: timerService.timeRemaining,
                totalDuration: totalDuration,
                isRunning: timerService.isRunning,
                overtimeSeconds: timerService.overtimeSeconds,
                periodLabel: periodLabel
            )
            .frame(maxWidth: 140)
            .contentShape(Circle())
        }
        // Pause/resume follows the Accidental tap lock like scoring and cards.
        .buttonStyle(WatchTapLockButtonStyle(progress: .ring))
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityValue(timerService.isInOvertime ? "Time up, \(timerService.overtimeSeconds) seconds over" : "")
        .accessibilityHint(timerService.isRunning ? "Pauses the match clock" : "Resumes the match clock")
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

    private func toggleClock() {
        HapticService.playStartStop()
        if timerService.isRunning {
            timerService.pause()
        } else {
            timerService.start()
        }
    }
}
