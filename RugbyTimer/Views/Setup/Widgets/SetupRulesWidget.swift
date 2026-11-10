import SwiftUI

struct SetupRulesWidget: View {
    @Binding var sinBinDurationSeconds: Int
    @Binding var halfTimeBreakSeconds: Int

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "03", title: "QUICK TOGGLES", detail: "RULE DEFAULTS")
            VStack(spacing: 0) {
                SetupSinBinDurationWidget(sinBinDurationSeconds: $sinBinDurationSeconds)
                Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                SetupHalfTimeBreakWidget(halfTimeBreakSeconds: $halfTimeBreakSeconds)
                Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                SetupTapLockWidget()
                Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                SetupCoinTossToggleWidget()
            }
            .buttonStyle(.plain)
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }
}
