import SwiftUI

struct SetupTapLockWidget: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(
                symbol: "hand.tap", title: "Accidental tap lock",
                subtitle: settings.tapLockEnabled ? "Hold to start, pause, score, card or end a half" : "Off · single tap on Watch",
                tint: Color.pitchEmerald
            )
            Spacer(minLength: 4)
            Toggle("Accidental tap lock", isOn: $settings.tapLockEnabled)
                .labelsHidden()
                .tint(Color.pitchEmerald)
                .onChange(of: settings.tapLockEnabled) { HapticService.playStartStop() }
        }
        .padding(14)
    }
}
