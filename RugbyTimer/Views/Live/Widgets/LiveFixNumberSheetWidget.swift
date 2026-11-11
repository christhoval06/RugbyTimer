import SwiftUI

/// Fixes the shirt number on a card shown to the wrong player number.
struct LiveFixNumberSheetWidget: View {
    let card: MatchCard
    let onSave: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var number: Int?

    init(card: MatchCard, onSave: @escaping (Int) -> Void) {
        self.card = card
        self.onSave = onSave
        _number = State(initialValue: card.playerNumber)
    }

    private var tint: Color { card.type == .yellow ? Color.cardYellow : Color.expulsionRed }
    private var canSave: Bool { number != nil && number != card.playerNumber }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LiveSheetHeaderWidget(eyebrow: "CORRECTION", title: "FIX SHIRT NUMBER", tint: tint) { dismiss() }
                    SetupSectionHeadingWidget(number: "#\(card.playerNumber)", title: LocalizedStringKey(card.teamName),
                                              detail: "PICK THE RIGHT NUMBER")
                    LivePlayerNumberGridWidget(selectedNumber: $number, tint: tint)
                }
                .padding(20)
            }
            Button {
                if let number { onSave(number) }
                dismiss()
            } label: {
                Text("SAVE NUMBER")
                    .font(.system(size: 17, weight: .black).width(.condensed))
                    .foregroundStyle(canSave ? Color.pitchVoid : Color.outline)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(canSave ? tint : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .padding(20)
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    LiveFixNumberSheetWidget(card: MatchCard(teamName: "City Lions", playerNumber: 8, type: .yellow)) { _ in }
        .preferredColorScheme(.dark)
}
