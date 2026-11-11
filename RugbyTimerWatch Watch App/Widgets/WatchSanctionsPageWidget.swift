import SwiftUI

struct WatchSanctionsPageWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let activeCards: [MatchCard]
    var matchEvents: [MatchEvent] = []
    /// Adds a 20' button next to RED, and makes a second yellow a 20-minute red.
    var twentyMinuteRedEnabled = false
    let onAddCard: (String, Int, Sanction) -> Void

    @State private var selectedTeam: String
    @State private var playerNumber: Int? = 8
    @State private var secondYellowNumber: Int?

    init(
        homeTeamName: String,
        awayTeamName: String,
        activeCards: [MatchCard],
        matchEvents: [MatchEvent] = [],
        twentyMinuteRedEnabled: Bool = false,
        onAddCard: @escaping (String, Int, Sanction) -> Void
    ) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.activeCards = activeCards
        self.matchEvents = matchEvents
        self.twentyMinuteRedEnabled = twentyMinuteRedEnabled
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
                    cardButton("YELLOW", sanction: .yellow, tint: .cardYellow, textColor: .pitchVoid)
                    if twentyMinuteRedEnabled {
                        cardButton("20'", sanction: .twentyMinuteRed, tint: .expulsionRed, textColor: .iceTitanium)
                    }
                    cardButton("RED", sanction: .red, tint: .expulsionRed, textColor: .iceTitanium)
                }

                if !activeCards.isEmpty {
                    WatchSinBinListWidget(cards: activeCards)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
        .confirmationDialog("SECOND YELLOW", isPresented: isAskingSecondYellow, titleVisibility: .visible) {
            Button(twentyMinuteRedEnabled ? "20-minute red" : "Red card", role: .destructive) {
                issue(.secondYellowRed, number: secondYellowNumber)
            }
            Button("Yellow only") { issue(.yellow, number: secondYellowNumber) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("#\(secondYellowNumber ?? 0) already has a yellow card.")
        }
    }

    private var isAskingSecondYellow: Binding<Bool> {
        Binding(get: { secondYellowNumber != nil }, set: { if !$0 { secondYellowNumber = nil } })
    }

    private func cardButton(_ title: LocalizedStringKey, sanction: Sanction, tint: Color, textColor: Color) -> some View {
        Button {
            guard let playerNumber else { return }
            // A second yellow for the same player is a red: ask before recording it.
            if sanction == .yellow,
               MatchEvent.hasYellow(in: matchEvents, team: selectedTeam, playerNumber: playerNumber) {
                secondYellowNumber = playerNumber
                return
            }
            issue(sanction, number: playerNumber)
        } label: {
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(textColor.opacity(0.85))
                    .frame(width: 6, height: 9)
                Text(title)
                    .font(.system(size: 12, weight: .heavy).width(.condensed))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(tint, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(WatchTapLockButtonStyle())
        .accessibilityLabel(accessibilityLabel(for: sanction))
    }

    private func issue(_ sanction: Sanction, number: Int?) {
        guard let number else { return }
        HapticService.playCardIssued()
        onAddCard(selectedTeam, number, sanction)
    }

    private func accessibilityLabel(for sanction: Sanction) -> Text {
        let number = playerNumber ?? 0
        switch sanction {
        case .yellow: return Text("Yellow card for number \(number), \(selectedTeam)")
        case .twentyMinuteRed: return Text("20-minute red card for number \(number), \(selectedTeam)")
        case .red, .secondYellowRed: return Text("Red card for number \(number), \(selectedTeam)")
        }
    }
}
