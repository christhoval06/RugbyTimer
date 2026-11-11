import SwiftUI

/// One answer in the Watch coin toss (a team, heads/tails, kick off/choose end).
struct WatchCoinTossOptionWidget: View {
    let title: LocalizedStringKey
    var detail: LocalizedStringKey? = nil
    var tint: Color = Color.iceTitanium
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .heavy).width(.condensed))
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let detail {
                    Text(detail)
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.outline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.45)))
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Toss option") {
    VStack {
        // Team names are never translated.
        WatchCoinTossOptionWidget(title: LocalizedStringKey(String("City Lions")), detail: "AWAY", // l10n-ignore
                                  tint: .sinBinAmber, action: {})
        WatchCoinTossOptionWidget(title: "HEADS", action: {})
    }
}
