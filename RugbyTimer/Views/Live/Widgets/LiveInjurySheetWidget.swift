import SwiftUI

/// Starts an HIA (12 min) or blood replacement (15 min) timer for a player.
struct LiveInjurySheetWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let onStart: (InjuryKind, String, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeam: String
    @State private var playerNumber: Int?

    init(homeTeamName: String, awayTeamName: String, onStart: @escaping (InjuryKind, String, Int) -> Void) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.onStart = onStart
        _selectedTeam = State(initialValue: homeTeamName)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LiveSheetHeaderWidget(eyebrow: "TEMPORARY REPLACEMENT", title: "INJURY", tint: Color.iceTitanium) {
                        dismiss()
                    }
                    VStack(spacing: 12) {
                        SetupSectionHeadingWidget(number: "01", title: "TEAM", detail: "INJURED PLAYER'S SIDE")
                        LiveTeamPickerWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName, selectedTeam: $selectedTeam)
                    }
                    VStack(spacing: 12) {
                        SetupSectionHeadingWidget(number: "02", title: "PLAYER",
                                                  detail: playerNumber.map { "#\($0)" as LocalizedStringKey } ?? "REQUIRED")
                        LivePlayerNumberGridWidget(selectedNumber: $playerNumber, tint: Color.iceTitanium)
                    }
                }
                .padding(20)
            }
            HStack(spacing: 10) {
                startButton("HIA · 12 MIN", kind: .hia, symbol: "brain.head.profile")
                startButton("BLOOD · 15 MIN", kind: .blood, symbol: "drop.fill")
            }
            .padding(20)
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private func startButton(_ title: LocalizedStringKey, kind: InjuryKind, symbol: String) -> some View {
        Button {
            guard let playerNumber else { return }
            onStart(kind, selectedTeam, playerNumber)
            dismiss()
        } label: {
            Label(title, systemImage: symbol)
                .font(.system(size: 15, weight: .black).width(.condensed))
                .foregroundStyle(playerNumber == nil ? Color.outline : Color.pitchVoid)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(playerNumber == nil ? Color.surfaceContainer : Color.iceTitanium,
                            in: RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .disabled(playerNumber == nil)
        .accessibilityIdentifier(kind == .hia ? "startHIA" : "startBlood")
    }
}

#Preview {
    LiveInjurySheetWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions") { _, _, _ in }
        .preferredColorScheme(.dark)
}
