import SwiftUI

struct WatchSinBinListWidget: View {
    let cards: [MatchCard]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SIN-BIN")
                .font(.system(size: 7, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(Color.outline)
            ForEach(cards) { card in
                WatchSinBinRowWidget(card: card)
            }
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }
}
