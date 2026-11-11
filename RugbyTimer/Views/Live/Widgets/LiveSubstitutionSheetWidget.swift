import SwiftUI

/// Records a substitution in iPhone-only mode: team, the number going off, the number coming on.
/// A likely mistake (limit reached, carded player, already replaced) asks before recording.
struct LiveSubstitutionSheetWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let rules: SubstitutionRules
    let events: [MatchEvent]
    let activeCards: [MatchCard]
    let onSubstitute: (String, Int, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeam: String
    @State private var offNumber: Int?
    @State private var onNumber: Int?
    @State private var warning: SubstitutionWarning?

    init(homeTeamName: String, awayTeamName: String, rules: SubstitutionRules, events: [MatchEvent],
         activeCards: [MatchCard], onSubstitute: @escaping (String, Int, Int) -> Void) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.rules = rules
        self.events = events
        self.activeCards = activeCards
        self.onSubstitute = onSubstitute
        _selectedTeam = State(initialValue: homeTeamName)
    }

    private var isReady: Bool { offNumber != nil && onNumber != nil && offNumber != onNumber }

    private var countDetail: LocalizedStringKey {
        let made = Substitution.count(in: events, team: selectedTeam)
        return rules.hasLimit ? "SUBS \(made)/\(rules.limit)" : "SUBS \(made)"
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LiveSheetHeaderWidget(eyebrow: "REPLACEMENT", title: "SUBSTITUTION", tint: Color.pitchEmerald) {
                        dismiss()
                    }
                    VStack(spacing: 12) {
                        SetupSectionHeadingWidget(number: "01", title: "TEAM", detail: countDetail)
                        LiveTeamPickerWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName, selectedTeam: $selectedTeam)
                    }
                    numberSection("02", title: "PLAYER OFF", number: $offNumber, tint: Color.sinBinAmber)
                    numberSection("03", title: "PLAYER ON", number: $onNumber, tint: Color.pitchEmerald)
                }
                .padding(20)
            }
            confirmButton.padding(20)
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .confirmationDialog("Check this substitution", isPresented: isWarning, titleVisibility: .visible) {
            Button("Record anyway") { record() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(verbatim: warning?.message ?? "")
        }
    }

    private func numberSection(_ step: String, title: LocalizedStringKey, number: Binding<Int?>,
                               tint: Color) -> some View {
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: step, title: title,
                                      detail: number.wrappedValue.map { "#\($0)" as LocalizedStringKey } ?? "REQUIRED")
            LivePlayerNumberGridWidget(selectedNumber: number, tint: tint)
        }
    }

    private var confirmButton: some View {
        Button {
            guard let offNumber, let onNumber else { return }
            warning = SubstitutionWarning.check(Substitution(off: offNumber, on: onNumber), team: selectedTeam,
                                                rules: rules, events: events, activeCards: activeCards)
            if warning == nil { record() }
        } label: {
            Group {
                if let offNumber, let onNumber, isReady {
                    Text("CONFIRM · #\(offNumber) OFF, #\(onNumber) ON")
                } else {
                    Text("PICK OFF AND ON NUMBERS")
                }
            }
            .font(.system(size: 17, weight: .black).width(.condensed))
            .foregroundStyle(isReady ? Color.pitchVoid : Color.outline)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(isReady ? Color.pitchEmerald : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .disabled(!isReady)
        .accessibilityIdentifier("confirmSubstitution")
    }

    private var isWarning: Binding<Bool> {
        Binding(get: { warning != nil }, set: { if !$0 { warning = nil } })
    }

    private func record() {
        guard let offNumber, let onNumber else { return }
        onSubstitute(selectedTeam, offNumber, onNumber)
        dismiss()
    }
}

#Preview {
    LiveSubstitutionSheetWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
                                rules: SubstitutionRules(isEnabled: true), events: [], activeCards: []) { _, _, _ in }
        .preferredColorScheme(.dark)
}
