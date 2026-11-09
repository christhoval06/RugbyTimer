import SwiftUI

/// A setting row whose value is picked from a fixed list of options.
struct SettingsMenuRowWidget: View {
    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let tint: Color
    let options: [(value: Int, label: String)]
    @Binding var selection: Int
    let valueLabel: String

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(symbol: symbol, title: title, subtitle: subtitle, tint: tint)
            Spacer(minLength: 4)
            Menu {
                Picker(title, selection: $selection) {
                    ForEach(options, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
            } label: {
                Label(valueLabel, systemImage: "chevron.down")
                    .font(.system(size: 13, weight: .heavy).width(.condensed))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .onChange(of: selection) { HapticService.playStartStop() }
            .accessibilityLabel(title)
            .accessibilityValue(valueLabel)
        }
        .padding(14)
    }
}
