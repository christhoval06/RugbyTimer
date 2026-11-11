import SwiftUI

/// Substitutions page, left of Sanctions: pick the team, the number going off and the number
/// coming on, then SUB. A likely mistake (limit reached, carded player, already replaced) asks first.
struct WatchSubstitutionsPageView: View {
    let homeTeamName: String
    let awayTeamName: String
    let rules: SubstitutionRules
    let matchEvents: [MatchEvent]
    let activeCards: [MatchCard]
    let onSubstitute: (String, Int, Int) -> Void

    @State private var selectedTeam: String?
    @State private var offNumber: Int?
    @State private var onNumber: Int?
    @State private var warning: SubstitutionWarning?

    private var team: String { selectedTeam ?? homeTeamName }
    private var isReady: Bool { offNumber != nil && onNumber != nil && offNumber != onNumber }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(eyebrow: "REPLACEMENT", title: "SUBSTITUTION", tint: .pitchEmerald)
                WatchTeamToggleWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                                      selectedTeam: Binding(get: { team }, set: { selectedTeam = $0 }))
                HStack(spacing: 4) {
                    numberColumn("PLAYER OFF", number: $offNumber, tint: .sinBinAmber)
                    numberColumn("PLAYER ON", number: $onNumber, tint: .pitchEmerald)
                }
                subButton
                WatchSubstitutionCountsWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                                              rules: rules, events: matchEvents)
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
        .confirmationDialog("Check this substitution", isPresented: isWarning, titleVisibility: .visible) {
            Button("Record anyway") { record() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(verbatim: warning?.message ?? "")
        }
    }

    private func numberColumn(_ title: LocalizedStringKey, number: Binding<Int?>, tint: Color) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 8, weight: .heavy))
                .tracking(0.7)
                .foregroundStyle(tint)
            WatchPlayerPickerWidget(playerNumber: number, allowsNone: true, noneLabel: "—")
        }
        .frame(maxWidth: .infinity)
    }

    private var subButton: some View {
        Button {
            guard let offNumber, let onNumber else { return }
            warning = SubstitutionWarning.check(Substitution(off: offNumber, on: onNumber), team: team,
                                                rules: rules, events: matchEvents, activeCards: activeCards)
            if warning == nil { record() }
        } label: {
            Label("SUB", systemImage: "arrow.left.arrow.right")
                .font(.system(size: 12, weight: .heavy).width(.condensed))
                .foregroundStyle(isReady ? Color.pitchVoid : Color.outline)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(isReady ? Color.pitchEmerald : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(WatchTapLockButtonStyle())
        .disabled(!isReady)
        .accessibilityLabel(subLabel)
    }

    private var subLabel: Text {
        guard let offNumber, let onNumber else { return Text("Substitution, pick the numbers first") }
        return Text("Substitution for \(team): number \(offNumber) off, number \(onNumber) on")
    }

    private var isWarning: Binding<Bool> {
        Binding(get: { warning != nil }, set: { if !$0 { warning = nil } })
    }

    private func record() {
        guard let offNumber, let onNumber else { return }
        HapticService.playStartStop()
        onSubstitute(team, offNumber, onNumber)
        self.offNumber = nil
        self.onNumber = nil
    }
}

#Preview {
    WatchSubstitutionsPageView(homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
                               rules: SubstitutionRules(isEnabled: true), matchEvents: [], activeCards: []) { _, _, _ in }
}
