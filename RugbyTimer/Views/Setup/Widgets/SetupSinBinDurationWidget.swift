import SwiftUI

struct SetupSinBinDurationWidget: View {
    @Binding var sinBinDurationSeconds: Int
    @State private var isEditingSinBinDuration = false
    @State private var customSinBinMinutes = ""

    var body: some View {
        HStack(spacing: 12) {
            SetupSettingLabelWidget(symbol: "rectangle.fill", title: "Sin-bin penalty", subtitle: "Yellow card countdown", tint: Color.sinBinAmber)
            Spacer(minLength: 4)
            Menu {
                Button("10 MIN") {
                    HapticService.playStartStop()
                    sinBinDurationSeconds = 600
                }
                Button("2 MIN") {
                    HapticService.playStartStop()
                    sinBinDurationSeconds = 120
                }
                Button("1 MIN") {
                    HapticService.playStartStop()
                    sinBinDurationSeconds = 60
                }
                Button("Custom…") {
                    customSinBinMinutes = String(sinBinDurationSeconds / 60)
                    isEditingSinBinDuration = true
                }
            } label: {
                Label("\(sinBinDurationSeconds / 60) MIN", systemImage: "chevron.down")
                    .font(.system(size: 13, weight: .heavy).width(.condensed))
                    .foregroundStyle(Color.sinBinAmber)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(Color.sinBinAmber.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Sin-bin duration")
            .accessibilityValue("\(sinBinDurationSeconds / 60) minutes")
        }
        .padding(14)
        .alert("Custom Sin-Bin Duration", isPresented: $isEditingSinBinDuration) {
            TextField("Minutes", text: $customSinBinMinutes)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}
            Button("Set Duration") {
                guard let seconds = customSinBinSeconds else { return }
                sinBinDurationSeconds = seconds
            }
            .disabled(customSinBinSeconds == nil)
        } message: {
            Text("Enter the yellow card countdown in minutes (a positive whole number).")
        }
    }

    private var customSinBinSeconds: Int? {
        guard let minutes = Int(customSinBinMinutes.trimmingCharacters(in: .whitespacesAndNewlines)),
              minutes > 0, minutes <= Int.max / 60 else { return nil }
        return minutes * 60
    }
}
