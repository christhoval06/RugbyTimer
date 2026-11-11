import SwiftUI

/// Elapsed and remaining time under the ring, matching the iPhone clock stats.
/// Elapsed keeps counting through overtime while remaining holds at 00:00.
struct WatchClockStatsWidget: View {
    @ObservedObject var timerService: MatchTimerService
    let totalDuration: Int

    private var elapsed: Int {
        max(0, totalDuration - timerService.timeRemaining + timerService.overtimeSeconds)
    }

    var body: some View {
        HStack(spacing: 0) {
            stat("ELAPSED", seconds: elapsed)
            Rectangle().fill(Color.armorBorder).frame(width: 1, height: 22)
            stat("REMAINING", seconds: timerService.timeRemaining)
        }
        .padding(.vertical, 5)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.armorBorder))
    }

    private func stat(_ title: LocalizedStringKey, seconds: Int) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 7, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(Color.outline)
            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
