import SwiftUI

struct LiveControlTileWidget: View {
    let symbol: String
    let title: LocalizedStringKey
    let tint: Color
    var isFilled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 16, weight: .black).width(.condensed))
                .tracking(0.5)
                .foregroundStyle(isFilled ? Color.pitchVoid : tint)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(isFilled ? tint : tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(isFilled ? tint : tint.opacity(0.35)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
