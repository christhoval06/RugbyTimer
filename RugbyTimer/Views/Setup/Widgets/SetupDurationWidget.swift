import SwiftUI

struct SetupDurationWidget: View {
    private static let presetSeconds = [2400, 1200, 420]
    @Binding var selectedDurationSeconds: Int
    @State private var isEditingCustomDuration = false
    @State private var customMinutes = ""
    @State private var isCustomDurationSelected: Bool

    init(selectedDurationSeconds: Binding<Int>) {
        self._selectedDurationSeconds = selectedDurationSeconds
        self._isCustomDurationSelected = State(initialValue: !Self.presetSeconds.contains(selectedDurationSeconds.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "02", title: "MATCH FORMAT", detail: "PER HALF")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                durationOption(minutes: 40, subtitle: "STANDARD XVs", seconds: 2400)
                durationOption(minutes: 20, subtitle: "YOUTH / LOWER GRADES", seconds: 1200)
                durationOption(minutes: 7, subtitle: "SEVENS", seconds: 420)
                Button {
                    HapticService.playStartStop()
                    customMinutes = String(selectedDurationSeconds / 60)
                    isEditingCustomDuration = true
                } label: {
                    SetupDurationTileWidget(
                        value: isCustomDurationSelected ? "\(selectedDurationSeconds / 60)" : "Custom",
                        subtitle: "YOUR HALF-LENGTH", selected: isCustomDurationSelected,
                        isCustom: !isCustomDurationSelected
                    )
                }
                .accessibilityIdentifier("customMatchDuration")
            }
            .buttonStyle(.plain)
        }
        // Keeps the tiles in sync when Settings changes the default half length.
        .onChange(of: selectedDurationSeconds) { _, seconds in
            isCustomDurationSelected = !Self.presetSeconds.contains(seconds)
        }
        .alert("Custom Half-Length", isPresented: $isEditingCustomDuration) {
            TextField("Minutes", text: $customMinutes)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {}
            Button("Set Duration") {
                guard let seconds = customDurationSeconds else { return }
                selectedDurationSeconds = seconds
                isCustomDurationSelected = true
            }
            .disabled(customDurationSeconds == nil)
        } message: {
            Text("Enter the number of minutes per half (a positive whole number).")
        }
    }

    private var customDurationSeconds: Int? {
        guard let minutes = Int(customMinutes.trimmingCharacters(in: .whitespacesAndNewlines)),
              minutes > 0, minutes <= Int.max / 120 else { return nil }
        return minutes * 60
    }

    private func durationOption(minutes: Int, subtitle: LocalizedStringKey, seconds: Int) -> some View {
        Button {
            HapticService.playStartStop()
            isCustomDurationSelected = false
            selectedDurationSeconds = seconds
        } label: {
            SetupDurationTileWidget(value: "\(minutes)", subtitle: subtitle,
                              selected: !isCustomDurationSelected && selectedDurationSeconds == seconds)
        }
        .accessibilityLabel(Text("\(minutes) minutes, \(Text(subtitle))"))
        .accessibilityAddTraits(!isCustomDurationSelected && selectedDurationSeconds == seconds ? .isSelected : [])
    }
}
