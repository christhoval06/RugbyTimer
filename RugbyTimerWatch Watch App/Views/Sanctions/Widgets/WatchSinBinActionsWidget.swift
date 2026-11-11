import SwiftUI

/// Options for a card already shown: end its countdown now, or fix a wrong shirt number.
struct WatchSinBinActionsWidget: View {
    let card: MatchCard
    let actions: OffFieldActions

    @Environment(\.dismiss) private var dismiss
    @State private var number: Int?

    init(card: MatchCard, actions: OffFieldActions) {
        self.card = card
        self.actions = actions
        _number = State(initialValue: card.playerNumber)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                WatchPageTitleWidget(eyebrow: LocalizedStringKey(card.teamName), title: "#\(card.playerNumber)",
                                     tint: card.type == .yellow ? .cardYellow : .expulsionRed)

                if card.countsDown && !card.isExpired {
                    WatchSanctionButtonWidget(
                        title: card.type == .yellow ? "END SIN-BIN NOW" : "ALLOW REPLACEMENT NOW",
                        tint: .sinBinAmber, textColor: .pitchVoid, showsCard: false,
                        accessibilityLabel: Text("End the countdown now")
                    ) {
                        actions.endSinBin(card.id)
                        dismiss()
                    }
                }

                Text("FIX SHIRT NUMBER")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(Color.outline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                WatchPlayerPickerWidget(playerNumber: $number)
                WatchSanctionButtonWidget(
                    title: "SAVE NUMBER", tint: .pitchEmerald, textColor: .pitchVoid,
                    isEnabled: number != nil && number != card.playerNumber, showsCard: false,
                    accessibilityLabel: Text("Save the shirt number")
                ) {
                    if let number { actions.fixNumber(card.id, number) }
                    dismiss()
                }
            }
            .scenePadding(.horizontal)
        }
    }
}

#Preview {
    WatchSinBinActionsWidget(
        card: MatchCard(teamName: "City Lions", playerNumber: 8, type: .yellow, durationSeconds: 252),
        actions: .preview
    )
}
