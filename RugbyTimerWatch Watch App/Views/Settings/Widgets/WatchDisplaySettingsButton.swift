import SwiftUI

struct WatchDisplaySettingsButton: View {
    @State private var showsSettings = false

    var body: some View {
        Button {
            showsSettings = true
        } label: {
            Label("Watch display settings", systemImage: "slider.horizontal.3")
                .font(.system(size: 11, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .frame(maxWidth: .infinity, minHeight: 36)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.armorBorder))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showsSettings) { WatchDisplaySettingsView() }
    }
}

#Preview {
    WatchDisplaySettingsButton()
        .padding()
}
