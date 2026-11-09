import SwiftUI

struct SettingsToggleRowWidget: View {
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var tint: Color = .pitchEmerald
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(symbol: symbol, title: title, subtitle: subtitle, tint: tint)
            Spacer(minLength: 4)
            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .tint(Color.pitchEmerald)
        }
        .padding(14)
    }
}
