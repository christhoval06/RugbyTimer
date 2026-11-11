import SwiftUI

/// Players off the field: cards and injury timers. With `actions` (the iPhone runs the match),
/// tapping a row offers to end it now, fix the shirt number, or close the injury.
struct LiveSinBinWidget: View {
    let cards: [MatchCard]
    var injuries: [InjuryTimer] = []
    var actions: OffFieldActions? = nil

    @State private var selectedCard: MatchCard?
    @State private var selectedInjury: InjuryTimer?
    @State private var renumberedCard: MatchCard?

    private var activeCount: Int { cards.filter { !$0.isExpired }.count + injuries.count }

    var body: some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "04", title: "SANCTIONS", detail: "\(activeCount) ACTIVE")
            VStack(spacing: 0) {
                if cards.isEmpty && injuries.isEmpty {
                    Label("No cards issued", systemImage: "checkmark.shield")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.outline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    if index > 0 { divider }
                    row { LiveSinBinRowWidget(card: card) } onTap: { selectedCard = card }
                }
                ForEach(injuries) { injury in
                    if !cards.isEmpty || injury.id != injuries.first?.id { divider }
                    row { LiveInjuryRowWidget(injury: injury) } onTap: { selectedInjury = injury }
                }
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
        .modifier(LiveOffFieldDialogsModifier(
            selectedCard: $selectedCard, selectedInjury: $selectedInjury,
            renumberedCard: $renumberedCard, actions: actions
        ))
    }

    private var divider: some View {
        Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
    }

    @ViewBuilder
    private func row<Row: View>(@ViewBuilder _ content: () -> Row, onTap: @escaping () -> Void) -> some View {
        if actions != nil {
            Button(action: onTap) { content().contentShape(Rectangle()) }
                .buttonStyle(.plain)
                .accessibilityHint("Opens options for this player")
        } else {
            content()
        }
    }
}
