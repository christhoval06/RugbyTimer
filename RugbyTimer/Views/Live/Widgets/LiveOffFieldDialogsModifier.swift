import SwiftUI

/// The options behind a tapped sanctions row: end a countdown now, fix a shirt number,
/// or close an HIA or blood timer.
struct LiveOffFieldDialogsModifier: ViewModifier {
    @Binding var selectedCard: MatchCard?
    @Binding var selectedInjury: InjuryTimer?
    @Binding var renumberedCard: MatchCard?
    let actions: OffFieldActions?

    func body(content: Content) -> some View {
        content
            .confirmationDialog("#\(selectedCard?.playerNumber ?? 0) · \(selectedCard?.teamName ?? "")",
                                isPresented: isPresented($selectedCard), titleVisibility: .visible,
                                presenting: selectedCard) { card in
                if card.countsDown && !card.isExpired {
                    Button(card.type == .yellow ? "End sin-bin now" : "Allow replacement now") {
                        actions?.endSinBin(card.id)
                    }
                }
                Button("Fix shirt number") { renumberedCard = card }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("#\(selectedInjury?.playerNumber ?? 0) · \(selectedInjury?.teamName ?? "")",
                                isPresented: isPresented($selectedInjury), titleVisibility: .visible,
                                presenting: selectedInjury) { injury in
                Button("Back on") { actions?.endInjury(injury.id, .returned) }
                Button("Permanently replaced", role: .destructive) { actions?.endInjury(injury.id, .replaced) }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $renumberedCard) { card in
                LiveFixNumberSheetWidget(card: card) { actions?.fixNumber(card.id, $0) }
            }
    }

    private func isPresented<Item>(_ item: Binding<Item?>) -> Binding<Bool> {
        Binding(get: { item.wrappedValue != nil }, set: { if !$0 { item.wrappedValue = nil } })
    }
}
