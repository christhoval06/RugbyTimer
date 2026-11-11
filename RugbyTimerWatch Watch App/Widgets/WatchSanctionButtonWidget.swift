import SwiftUI

/// A card or injury button on the sanctions page. Greyed out until a shirt number is picked.
struct WatchSanctionButtonWidget: View {
    let title: LocalizedStringKey
    let tint: Color
    let textColor: Color
    var isEnabled = true
    var showsCard = true
    let accessibilityLabel: Text
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if showsCard {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(textColor.opacity(0.85))
                        .frame(width: 6, height: 9)
                }
                Text(title)
                    .font(.system(size: 12, weight: .heavy).width(.condensed))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isEnabled ? textColor : Color.outline)
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(isEnabled ? tint : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(WatchTapLockButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    VStack {
        WatchSanctionButtonWidget(title: "YELLOW", tint: .cardYellow, textColor: .pitchVoid,
                                  accessibilityLabel: Text(verbatim: "Yellow"), action: {})
        WatchSanctionButtonWidget(title: "HIA 12'", tint: .surfaceContainer, textColor: .iceTitanium,
                                  isEnabled: false, showsCard: false, accessibilityLabel: Text(verbatim: "HIA"), action: {})
    }
    .padding()
}
