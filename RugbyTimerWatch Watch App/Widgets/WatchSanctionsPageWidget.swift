import SwiftUI

struct WatchSanctionsPageWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let activeCards: [MatchCard]
    let onAddCard: (String, Int, CardType) -> Void

    @State private var selectedTeam: String
    @State private var playerNumber: Int? = 8

    init(
        homeTeamName: String,
        awayTeamName: String,
        activeCards: [MatchCard],
        onAddCard: @escaping (String, Int, CardType) -> Void
    ) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.activeCards = activeCards
        self.onAddCard = onAddCard
        _selectedTeam = State(initialValue: homeTeamName)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(eyebrow: "DISCIPLINE", title: "SANCTION", tint: .cardYellow)

                WatchTeamToggleWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName,
                    selectedTeam: $selectedTeam
                )

                WatchPlayerPickerWidget(playerNumber: $playerNumber)

                HStack(spacing: 6) {
                    cardButton("YELLOW", type: .yellow, tint: .cardYellow, textColor: .pitchVoid)
                    cardButton("RED", type: .red, tint: .expulsionRed, textColor: .iceTitanium)
                }

                if !activeCards.isEmpty {
                    WatchSinBinListWidget(cards: activeCards)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }

    private func cardButton(_ title: LocalizedStringKey, type: CardType, tint: Color, textColor: Color) -> some View {
        Button {
            guard let playerNumber else { return }
            HapticService.playCardIssued()
            onAddCard(selectedTeam, playerNumber, type)
        } label: {
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(textColor.opacity(0.85))
                    .frame(width: 6, height: 9)
                Text(title)
                    .font(.system(size: 12, weight: .heavy).width(.condensed))
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(tint, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(WatchTapLockButtonStyle())
        .accessibilityLabel(type == .yellow
            ? "Yellow card for number \(playerNumber ?? 0), \(selectedTeam)"
            : "Red card for number \(playerNumber ?? 0), \(selectedTeam)")
    }
}
