import SwiftUI

/// A setting row whose value is picked from a list of options in seconds. With `custom`,
/// the menu also offers "Custom…", which asks for a whole number of minutes.
struct SettingsMenuRowWidget: View {
    struct Custom {
        let title: LocalizedStringKey
        let message: LocalizedStringKey
        var range: ClosedRange<Int> = 1...(Int.max / 120)
    }

    let symbol: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let tint: Color
    let options: [(value: Int, label: String)]
    @Binding var selection: Int
    let valueLabel: String
    var custom: Custom? = nil

    @State private var isEditingCustom = false

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
                if custom != nil {
                    Button("Custom…") { isEditingCustom = true }
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
        .minutesEntryAlert(custom?.title ?? "", message: custom?.message ?? "",
                           isPresented: $isEditingCustom, currentSeconds: selection,
                           range: custom?.range ?? 1...1) { selection = $0 }
    }
}
