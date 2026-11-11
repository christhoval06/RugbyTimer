import SwiftUI

/// Shown in place of START MATCH until the coin toss is done.
struct WatchCoinTossButtonWidget: View {
    let onTossCoin: () -> Void

    var body: some View {
        Button(action: onTossCoin) {
            HStack(spacing: 6) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 22, height: 22)
                    .background(Color.pitchVoid.opacity(0.12), in: Circle())
                Text("COIN TOSS")
                    .font(.system(size: 12, weight: .heavy).width(.condensed))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
            }
            .padding(.horizontal, 10)
            .foregroundStyle(Color.pitchVoid)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(Color.sinBinAmber, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("COIN TOSS")
        .accessibilityHint("Toss the coin to decide who kicks off. Required before the match starts")
    }
}

#Preview("Coin toss button") {
    WatchCoinTossButtonWidget(onTossCoin: {})
        .padding()
}
