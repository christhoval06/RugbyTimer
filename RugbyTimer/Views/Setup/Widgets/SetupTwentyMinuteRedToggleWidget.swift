import SwiftUI

/// World Rugby's 20-minute red card: the player is sent off, and a replacement can come on
/// after 20 minutes. Competitions opt in, so it's a per-match rule.
struct SetupTwentyMinuteRedToggleWidget: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(
                symbol: "rectangle.portrait.on.rectangle.portrait.fill", title: "20-minute red card",
                subtitle: settings.twentyMinuteRedEnabled
                    ? "Replacement after 20 min · second yellow too"
                    : "Off · red cards are full send-offs",
                tint: Color.expulsionRed
            )
            Spacer(minLength: 4)
            Toggle("20-minute red card", isOn: $settings.twentyMinuteRedEnabled)
                .labelsHidden()
                .tint(Color.pitchEmerald)
                .onChange(of: settings.twentyMinuteRedEnabled) { HapticService.playStartStop() }
                .accessibilityIdentifier("setup.twentyMinuteRed.toggle")
        }
        .padding(14)
    }
}

#Preview("20-minute red toggle") {
    SetupTwentyMinuteRedToggleWidget()
        .environmentObject(AppSettings())
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
