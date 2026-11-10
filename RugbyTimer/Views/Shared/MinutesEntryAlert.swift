import SwiftUI

/// The "Custom…" dialog behind every minutes picker: a number field, Cancel and Set Duration.
/// Whole minutes inside `range` are accepted and handed back in seconds.
struct MinutesEntryAlert: ViewModifier {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    @Binding var isPresented: Bool
    let currentSeconds: Int
    var range: ClosedRange<Int> = 1...(Int.max / 120)
    let onSet: (Int) -> Void

    @State private var minutes = ""

    private var enteredSeconds: Int? {
        guard let value = Int(minutes.trimmingCharacters(in: .whitespacesAndNewlines)),
              range.contains(value) else { return nil }
        return value * 60
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, presented in
                if presented { minutes = String(currentSeconds / 60) }
            }
            .alert(title, isPresented: $isPresented) {
                TextField("Minutes", text: $minutes)
                    .keyboardType(.numberPad)
                Button("Cancel", role: .cancel) {}
                Button("Set Duration") {
                    guard let enteredSeconds else { return }
                    HapticService.playStartStop()
                    onSet(enteredSeconds)
                }
                .disabled(enteredSeconds == nil)
            } message: {
                Text(message)
            }
    }
}

extension View {
    func minutesEntryAlert(
        _ title: LocalizedStringKey, message: LocalizedStringKey, isPresented: Binding<Bool>,
        currentSeconds: Int, range: ClosedRange<Int> = 1...(Int.max / 120), onSet: @escaping (Int) -> Void
    ) -> some View {
        modifier(MinutesEntryAlert(title: title, message: message, isPresented: isPresented,
                                   currentSeconds: currentSeconds, range: range, onSet: onSet))
    }
}
