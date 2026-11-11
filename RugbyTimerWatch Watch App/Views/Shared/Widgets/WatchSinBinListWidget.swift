import SwiftUI

/// Players off the field: sin-bins, red cards and injury timers. With `actions`, tapping a
/// row opens what the referee can do about it (end now, fix the number, back on or replaced).
struct WatchSinBinListWidget: View {
    let cards: [MatchCard]
    var injuries: [InjuryTimer] = []
    var title: LocalizedStringKey = "SIN-BIN"
    var actions: OffFieldActions? = nil

    @State private var editedCard: MatchCard?
    @State private var editedInjury: InjuryTimer?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 7, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(Color.outline)
            ForEach(cards) { card in
                row { WatchSinBinRowWidget(card: card) } onTap: { editedCard = card }
            }
            ForEach(injuries) { injury in
                row { WatchInjuryRowWidget(injury: injury) } onTap: { editedInjury = injury }
            }
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
        .sheet(item: $editedCard) { card in
            if let actions {
                WatchSinBinActionsWidget(card: card, actions: actions)
            }
        }
        .sheet(item: $editedInjury) { injury in
            if let actions {
                WatchInjuryActionsWidget(injury: injury, actions: actions)
            }
        }
    }

    @ViewBuilder
    private func row<Row: View>(@ViewBuilder _ content: () -> Row, onTap: @escaping () -> Void) -> some View {
        if actions != nil {
            Button(action: onTap) { content() }
                .buttonStyle(.plain)
                .accessibilityHint("Opens options for this player")
        } else {
            content()
        }
    }
}

#Preview {
    WatchSinBinListWidget(
        cards: [MatchCard(teamName: "City Lions", playerNumber: 8, type: .yellow, durationSeconds: 252)],
        injuries: [InjuryTimer(teamName: "Rangers RFC", playerNumber: 12, kind: .blood)],
        actions: .preview
    )
    .padding()
}
