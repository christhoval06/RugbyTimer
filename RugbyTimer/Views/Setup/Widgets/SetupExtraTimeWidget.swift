import SwiftUI

/// Extra time for knockout matches: off, two 10-minute halves then sudden death (fifteens),
/// or 5-minute sudden-death periods (sevens). Only used when the match is level at full time.
struct SetupExtraTimeWidget: View {
    @EnvironmentObject private var settings: AppSettings

    private var subtitle: LocalizedStringKey {
        switch settings.extraTimeFormat {
        case .off: "Off · a level match ends as a draw"
        case .twoHalves: "2 × 10 min, then sudden death"
        case .suddenDeath: "Sudden death · 5 min periods"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(symbol: "clock.badge.exclamationmark", title: "Extra time",
                                    subtitle: subtitle, tint: Color.sinBinAmber)
            Spacer(minLength: 4)
            Picker("Extra time", selection: $settings.extraTimeFormat) {
                Text("Off").tag(ExtraTimeFormat.off)
                Text("Fifteens").tag(ExtraTimeFormat.twoHalves)
                Text("Sevens").tag(ExtraTimeFormat.suddenDeath)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(Color.pitchEmerald)
            .onChange(of: settings.extraTimeFormat) { HapticService.playStartStop() }
            .accessibilityIdentifier("setup.extraTime.picker")
        }
        .padding(14)
    }
}

#Preview("Extra time") {
    SetupExtraTimeWidget()
        .environmentObject(AppSettings())
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
