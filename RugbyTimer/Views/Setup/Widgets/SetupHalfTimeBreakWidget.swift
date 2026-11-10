import SwiftUI

/// Half-time interval for this match: presets plus a custom length, counted down on the Watch.
struct SetupHalfTimeBreakWidget: View {
    static let presetMinutes = [2, 5, 10, 15]
    static let customRange = 1...30

    @Binding var halfTimeBreakSeconds: Int
    @State private var isEditingCustom = false

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(symbol: "cup.and.saucer", title: "Half-time break",
                                    subtitle: "Countdown on the Watch", tint: Color.iceTitanium)
            Spacer(minLength: 4)
            Menu {
                ForEach(Self.presetMinutes, id: \.self) { minutes in
                    Button("\(minutes) MIN") {
                        HapticService.playStartStop()
                        halfTimeBreakSeconds = minutes * 60
                    }
                }
                Button("Custom…") { isEditingCustom = true }
            } label: {
                Label("\(halfTimeBreakSeconds / 60) MIN", systemImage: "chevron.down")
                    .font(.system(size: 13, weight: .heavy).width(.condensed))
                    .foregroundStyle(Color.iceTitanium)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(Color.iceTitanium.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Half-time break duration")
            .accessibilityValue("\(halfTimeBreakSeconds / 60) minutes")
        }
        .padding(14)
        .minutesEntryAlert("Custom Half-Time Break",
                           message: "Enter the half-time break in minutes (1–30).",
                           isPresented: $isEditingCustom, currentSeconds: halfTimeBreakSeconds,
                           range: Self.customRange) { halfTimeBreakSeconds = $0 }
    }
}

#Preview("Half-time break") {
    @Previewable @State var seconds = 120
    SetupHalfTimeBreakWidget(halfTimeBreakSeconds: $seconds)
        .background(Color.surfaceContainer)
        .preferredColorScheme(.dark)
}
