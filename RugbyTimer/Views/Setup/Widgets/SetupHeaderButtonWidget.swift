import SwiftUI

/// A square icon button in the Match Setup header (Match History, Settings).
struct SetupHeaderButtonWidget: View {
    let symbol: String
    let label: LocalizedStringKey
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.playStartStop()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Color.pitchEmerald)
                .frame(width: 52, height: 52)
                .background(Color.pitchEmerald.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.pitchEmerald.opacity(0.2)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityIdentifier(identifier)
    }
}

#Preview {
    SetupHeaderButtonWidget(symbol: "gearshape", label: "Settings", identifier: "openSettings") {}
        .padding()
        .background(Color.pitchVoid)
}
