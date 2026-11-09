import SwiftUI

struct SettingsResetWidget: View {
    let onReset: () -> Void
    @State private var isConfirming = false

    var body: some View {
        Button {
            isConfirming = true
        } label: {
            Label("Restore default settings", systemImage: "arrow.counterclockwise")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.expulsionRed)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.expulsionRed.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.expulsionRed.opacity(0.25)))
        }
        .buttonStyle(.plain)
        .confirmationDialog("Restore default settings?", isPresented: $isConfirming, titleVisibility: .visible) {
            Button("Restore Defaults", role: .destructive) {
                HapticService.playCardIssued()
                onReset()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Half length, sin-bin, teams, shirt numbers, tap lock and toggles go back to their standard values.")
        }
    }
}
