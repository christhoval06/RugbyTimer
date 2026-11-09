import SwiftUI

struct LiveSinBinWidget: View {
    let cards: [MatchCard]

    private var activeCount: Int { cards.filter { !$0.isExpired }.count }

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "04", title: "SANCTIONS", detail: "\(activeCount) ACTIVE")
            VStack(spacing: 0) {
                if cards.isEmpty {
                    Label("No cards issued", systemImage: "checkmark.shield")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.outline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                } else {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        if index > 0 {
                            Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                        }
                        LiveSinBinRowWidget(card: card)
                    }
                }
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }
}
