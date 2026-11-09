import SwiftUI

struct LiveClockStatsWidget: View {
    let timeRemaining: Int
    let totalDuration: Int
    let overtimeSeconds: Int

    var body: some View {
        HStack(spacing: 0) {
            stat("ELAPSED", seconds: totalDuration - timeRemaining + overtimeSeconds, tint: Color.iceTitanium)
            divider
            stat("REMAINING", seconds: timeRemaining, tint: Color.iceTitanium)
            divider
            stat("HALF", seconds: totalDuration, tint: Color.outline)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .top) { Color.armorBorder.frame(height: 1) }
    }

    private var divider: some View {
        Rectangle().fill(Color.armorBorder).frame(width: 1, height: 28)
    }

    private func stat(_ title: LocalizedStringKey, seconds: Int, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(Color.outline)
            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
