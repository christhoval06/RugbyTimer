import SwiftUI

/// Cards and injury timers: pick the team and shirt number, then the card or the injury.
struct WatchSanctionsPageView: View {
    let homeTeamName: String
    let awayTeamName: String
    let activeCards: [MatchCard]
    var injuries: [InjuryTimer] = []
    var matchEvents: [MatchEvent] = []
    var twentyMinuteRedEnabled = false
    var actions: OffFieldActions? = nil
    var fixedTeam: String? = nil
    var showsCards = true
    var dismissesAfterInjury = false
    var onStartInjury: (InjuryKind, String, Int) -> Void = { _, _, _ in }
    let onAddCard: (String, Int, Sanction) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeam: String?
    @State private var playerNumber: Int?
    @State private var secondYellowNumber: Int?

    private var team: String { fixedTeam ?? selectedTeam ?? homeTeamName }

    var body: some View {
        Group {
            if fixedTeam != nil {
                form
            } else {
                ScrollView {
                    form.padding(.vertical, 4).scenePadding(.horizontal)
                }
            }
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

    private var form: some View {
        VStack(spacing: 6) {
            if fixedTeam == nil {
                WatchPageTitleWidget(eyebrow: "DISCIPLINE", title: showsCards ? "SANCTION" : "INJURY", tint: .cardYellow)
                WatchTeamToggleWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                                      selectedTeam: Binding(get: { team }, set: { selectedTeam = $0 }))
            }
            WatchPlayerPickerWidget(playerNumber: $playerNumber, allowsNone: true, noneLabel: "— PICK #")
            if showsCards {
                HStack(spacing: 6) {
                    cardButton("YELLOW", .yellow, tint: .cardYellow, text: .pitchVoid)
                    if twentyMinuteRedEnabled { cardButton("20'", .twentyMinuteRed, tint: .expulsionRed, text: .iceTitanium) }
                    cardButton("RED", .red, tint: .expulsionRed, text: .iceTitanium)
                }
            }
            if fixedTeam == nil || !showsCards {
                HStack(spacing: 6) {
                    injuryButton("HIA 12'", .hia)
                    injuryButton("BLOOD 15'", .blood)
                }
            }
            if !activeCards.isEmpty || !injuries.isEmpty {
                WatchSinBinListWidget(cards: activeCards, injuries: injuries, title: "OFF THE FIELD", actions: actions)
            }
        }
    }

    private var isAskingSecondYellow: Binding<Bool> {
        Binding(get: { secondYellowNumber != nil }, set: { if !$0 { secondYellowNumber = nil } })
    }

    private func cardButton(_ title: LocalizedStringKey, _ sanction: Sanction, tint: Color, text: Color) -> some View {
        WatchSanctionButtonWidget(title: title, tint: tint, textColor: text, isEnabled: playerNumber != nil,
                                  accessibilityLabel: label(for: sanction)) {
            guard let playerNumber else { return }
            if sanction == .yellow, MatchEvent.hasYellow(in: matchEvents, team: team, playerNumber: playerNumber) {
                secondYellowNumber = playerNumber
                return
            }
            issue(sanction, number: playerNumber)
        }
    }

    private func injuryButton(_ title: LocalizedStringKey, _ kind: InjuryKind) -> some View {
        WatchSanctionButtonWidget(title: title, tint: .iceTitanium, textColor: .pitchVoid, isEnabled: playerNumber != nil,
                                  showsCard: false,
                                  accessibilityLabel: kind == .hia ? Text("Start HIA, 12 minutes") : Text("Start blood replacement, 15 minutes")) {
            guard let playerNumber else { return }
            onStartInjury(kind, team, playerNumber)
            self.playerNumber = nil
            if dismissesAfterInjury { dismiss() }
        }
    }

    private func issue(_ sanction: Sanction, number: Int?) {
        guard let number else { return }
        HapticService.playCardIssued()
        onAddCard(team, number, sanction)
        playerNumber = nil
    }

    private func label(for sanction: Sanction) -> Text {
        let number = playerNumber ?? 0
        switch sanction {
        case .yellow: return Text("Yellow card for number \(number), \(team)")
        case .twentyMinuteRed: return Text("20-minute red card for number \(number), \(team)")
        case .red, .secondYellowRed: return Text("Red card for number \(number), \(team)")
        }
    }
}

#Preview {
    WatchSanctionsPageView(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", activeCards: []) { _, _, _ in }
}
