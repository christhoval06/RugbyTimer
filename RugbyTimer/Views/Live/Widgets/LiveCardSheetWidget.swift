import SwiftUI

struct LiveCardSheetWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    var matchEvents: [MatchEvent] = []
    var twentyMinuteRedEnabled = false
    let onCard: (String, Int, Sanction) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeam: String
    @State private var sanction: Sanction = .yellow
    @State private var playerNumber: Int?
    @State private var isAskingSecondYellow = false

    init(homeTeamName: String, awayTeamName: String, matchEvents: [MatchEvent] = [],
         twentyMinuteRedEnabled: Bool = false, onCard: @escaping (String, Int, Sanction) -> Void) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.matchEvents = matchEvents
        self.twentyMinuteRedEnabled = twentyMinuteRedEnabled
        self.onCard = onCard
        _selectedTeam = State(initialValue: homeTeamName)
    }

    private var confirmTitle: Text {
        guard let playerNumber else { return Text("SELECT A PLAYER") }
        switch sanction {
        case .yellow: return Text("CONFIRM YELLOW · #\(playerNumber)")
        case .twentyMinuteRed: return Text("CONFIRM 20-MIN RED · #\(playerNumber)")
        case .red, .secondYellowRed: return Text("CONFIRM RED · #\(playerNumber)")
        }
    }

    private var tint: Color { sanction == .yellow ? Color.cardYellow : Color.expulsionRed }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LiveSheetHeaderWidget(eyebrow: "DISCIPLINE", title: "ISSUE CARD", tint: tint) { dismiss() }

                    HStack(spacing: 10) {
                        typeTile("YELLOW", .yellow, tint: Color.cardYellow)
                        if twentyMinuteRedEnabled { typeTile("RED 20'", .twentyMinuteRed, tint: Color.expulsionRed) }
                        typeTile("RED", .red, tint: Color.expulsionRed)
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

            Button(action: confirm) {
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
        .confirmationDialog("SECOND YELLOW", isPresented: $isAskingSecondYellow, titleVisibility: .visible) {
            Button(twentyMinuteRedEnabled ? "Show a 20-minute red" : "Show a red card", role: .destructive) {
                record(.secondYellowRed)
            }
            Button("Record a yellow only") { record(.yellow) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("#\(playerNumber ?? 0) already has a yellow card. A second yellow is a red card.")
        }
    }

    private func typeTile(_ title: LocalizedStringKey, _ type: Sanction, tint: Color) -> some View {
        LiveControlTileWidget(symbol: "rectangle.portrait.fill", title: title, tint: tint,
                              isFilled: sanction == type) { sanction = type }
    }

    private func confirm() {
        guard let playerNumber else { return }
        if sanction == .yellow, MatchEvent.hasYellow(in: matchEvents, team: selectedTeam, playerNumber: playerNumber) {
            isAskingSecondYellow = true
            return
        }
        record(sanction)
    }

    private func record(_ chosen: Sanction) {
        guard let playerNumber else { return }
        HapticService.playCardIssued()
        onCard(selectedTeam, playerNumber, chosen)
        dismiss()
    }
}
