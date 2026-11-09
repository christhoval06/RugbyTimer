import SwiftUI

struct SetupSecondaryActionWidget: View {
    let symbol: String
    let title: LocalizedStringKey
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticService.playStartStop()
            action()
        } label: {
            Label(title, systemImage: symbol)
                .font(.system(size: 14, weight: .heavy).width(.condensed))
                .tracking(0.6)
                .foregroundStyle(Color.pitchEmerald)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
                .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }
}
