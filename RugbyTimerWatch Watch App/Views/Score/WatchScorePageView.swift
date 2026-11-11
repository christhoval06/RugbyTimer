import SwiftUI

struct WatchScorePageView: View {
    let homeTeamName: String
    let awayTeamName: String
    let homeScore: Int
    let awayScore: Int
    let onScore: (String, Int?, Int, String) -> Void

    @State private var selectedTeam: String
    @State private var scorer: Int?

    /// `description` stays English because it is synced to the iPhone; `label` is what the referee reads.
    private static let scoreTypes: [ScoreType] = [
        ScoreType(id: "TRY", label: "TRY", points: 5, description: "Try scored (+5)"),
        ScoreType(id: "CONV", label: "CONV", points: 2, description: "Conversion (+2)"),
        ScoreType(id: "PEN", label: "PEN", points: 3, description: "Penalty goal (+3)"),
        ScoreType(id: "DROP", label: "DROP", points: 3, description: "Drop goal (+3)"),
        ScoreType(id: "PT", label: "PEN TRY", points: 7, description: "Penalty try (+7)")
    ]

    init(
        homeTeamName: String,
        awayTeamName: String,
        homeScore: Int,
        awayScore: Int,
        onScore: @escaping (String, Int?, Int, String) -> Void
    ) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.onScore = onScore
        _selectedTeam = State(initialValue: homeTeamName)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                HStack(alignment: .bottom) {
                    WatchPageTitleWidget(eyebrow: "POINTS", title: "SCORE", tint: .pitchEmerald)
                    Text("\(homeScore)–\(awayScore)")
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color.iceTitanium)
                        .fixedSize()
                        .accessibilityLabel("\(homeScore) to \(awayScore)")
                }

                WatchTeamToggleWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName,
                    selectedTeam: $selectedTeam
                )
                .onChange(of: selectedTeam) { scorer = nil }

                WatchPlayerPickerWidget(playerNumber: $scorer, allowsNone: true)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                    ForEach(Self.scoreTypes.dropLast(), id: \.id) { scoreType in
                        scoreButton(scoreType)
                    }
                }
                // The penalty try gets the full width under the grid.
                if let penaltyTry = Self.scoreTypes.last { scoreButton(penaltyTry) }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
    }

    private func scoreButton(_ scoreType: ScoreType) -> some View {
        Button {
            HapticService.playStartStop()
            onScore(selectedTeam, scorer, scoreType.points, scoreType.description)
            scorer = nil
        } label: {
            VStack(spacing: 0) {
                Text("+\(scoreType.points)")
                    .font(.system(size: 16, weight: .heavy, design: .monospaced))
                Text(scoreType.label)
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.6)
            }
            .foregroundStyle(scoreType.isTry ? Color.pitchVoid : Color.iceTitanium)
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(
                scoreType.isTry ? Color.pitchEmerald : Color.surfaceContainer,
                in: RoundedRectangle(cornerRadius: 11)
            )
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
        }
        .buttonStyle(WatchTapLockButtonStyle())
        .accessibilityLabel(scoreAccessibilityLabel(scoreType))
    }

    private func scoreAccessibilityLabel(_ scoreType: ScoreType) -> String {
        let event = MatchEvent(minute: 0, teamName: selectedTeam, type: .tryScore(points: scoreType.points),
                               description: scoreType.description)
        guard let scorer else { return String(appLocalized: "\(event.localizedDescription) for \(selectedTeam)") }
        return String(appLocalized: "\(event.localizedDescription) for \(selectedTeam), number \(scorer)")
    }
}

private struct ScoreType {
    let id: String
    let label: LocalizedStringKey
    let points: Int
    let description: String

    var isTry: Bool { id == "TRY" }
}
