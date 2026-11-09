import SwiftUI

struct LiveCardSheetWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let onCard: (String, Int, CardType) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeam: String
    @State private var cardType: CardType = .yellow
    @State private var playerNumber: Int?

    init(homeTeamName: String, awayTeamName: String, onCard: @escaping (String, Int, CardType) -> Void) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.onCard = onCard
        _selectedTeam = State(initialValue: homeTeamName)
    }

    private var confirmTitle: Text {
        guard let playerNumber else { return Text("SELECT A PLAYER") }
        return cardType == .yellow ? Text("CONFIRM YELLOW · #\(playerNumber)") : Text("CONFIRM RED · #\(playerNumber)")
    }

    private var tint: Color { cardType == .yellow ? Color.cardYellow : Color.expulsionRed }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LiveSheetHeaderWidget(eyebrow: "DISCIPLINE", title: "ISSUE CARD", tint: tint) { dismiss() }

                    HStack(spacing: 10) {
                        LiveControlTileWidget(symbol: "rectangle.portrait.fill", title: "YELLOW", tint: Color.cardYellow,
                                              isFilled: cardType == .yellow) { cardType = .yellow }
                        LiveControlTileWidget(symbol: "rectangle.portrait.fill", title: "RED", tint: Color.expulsionRed,
                                              isFilled: cardType == .red) { cardType = .red }
                    }

                    VStack(spacing: 12) {
                        SetupSectionHeadingWidget(number: "01", title: "TEAM", detail: "OFFENDING SIDE")
                        LiveTeamPickerWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName, selectedTeam: $selectedTeam)
                    }

                    VStack(spacing: 12) {
                        SetupSectionHeadingWidget(number: "02", title: "PLAYER", detail: playerNumber.map { "#\($0)" as LocalizedStringKey } ?? "REQUIRED")
                        LivePlayerNumberGridWidget(selectedNumber: $playerNumber, tint: tint)
                    }
                }
                .padding(20)
            }

            Button {
                guard let playerNumber else { return }
                HapticService.playCardIssued()
                onCard(selectedTeam, playerNumber, cardType)
                dismiss()
            } label: {
                confirmTitle
                    .font(.system(size: 17, weight: .black).width(.condensed))
                    .foregroundStyle(playerNumber == nil ? Color.outline : Color.pitchVoid)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(playerNumber == nil ? Color.surfaceContainer : tint, in: RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
            .disabled(playerNumber == nil)
            .accessibilityIdentifier("confirmCard")
            .padding(20)
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }
}
