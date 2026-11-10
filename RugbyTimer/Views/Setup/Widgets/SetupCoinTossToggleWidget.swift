import SwiftUI

struct SetupCoinTossToggleWidget: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(
                symbol: "circle.lefthalf.filled", title: "Coin toss",
                subtitle: settings.coinTossEnabled ? "On the Watch before kick-off" : "Off · kick off without a toss",
                tint: Color.sinBinAmber
            )
            Spacer(minLength: 4)
            Toggle("Coin toss", isOn: $settings.coinTossEnabled)
                .labelsHidden()
                .tint(Color.pitchEmerald)
                .onChange(of: settings.coinTossEnabled) { HapticService.playStartStop() }
                .accessibilityIdentifier("setup.coinToss.toggle")
        }
        .padding(14)
    }
}

#Preview("Coin toss toggle") {
    SetupCoinTossToggleWidget()
        .environmentObject(AppSettings())
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
