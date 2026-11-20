import SwiftUI

struct WatchDisplaySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                WatchDisplayTogglesWidget()
            }
            .navigationTitle("Watch display settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    WatchDisplaySettingsView()
}
