import SwiftUI

struct WatchScorePageView: View {
    let homeTeamName: String
    let awayTeamName: String
    let homeScore: Int
    let awayScore: Int
    let onScore: (String, Int?, Int, String) -> Void

    let fixedTeam: String?

    @State private var selectedTeam: String
    @State private var scorer: Int?

    init(
        homeTeamName: String,
        awayTeamName: String,
        homeScore: Int,
        awayScore: Int,
        fixedTeam: String? = nil,
        onScore: @escaping (String, Int?, Int, String) -> Void
    ) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.onScore = onScore
        self.fixedTeam = fixedTeam
        _selectedTeam = State(initialValue: fixedTeam ?? homeTeamName)
    }

    var body: some View {
        if fixedTeam != nil {
            scoringControls
        } else {
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
                    WatchTeamToggleWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                                          selectedTeam: $selectedTeam)
                        .onChange(of: selectedTeam) { scorer = nil }
                    scoringControls
                }
                .padding(.vertical, 4)
                .scenePadding(.horizontal)
            }
        }
    }

    private var scoringControls: some View {
        VStack(spacing: 6) {
            WatchPlayerPickerWidget(playerNumber: $scorer, allowsNone: true)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                ForEach(WatchScoreType.all.dropLast(), id: \.id) { scoreButton($0) }
            }
            if let penaltyTry = WatchScoreType.all.last { scoreButton(penaltyTry) }
        }
    }

    private func scoreButton(_ scoreType: WatchScoreType) -> some View {
        Button {
            HapticService.playStartStop()
            onScore(fixedTeam ?? selectedTeam, scorer, scoreType.points, scoreType.description)
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

    private func scoreAccessibilityLabel(_ scoreType: WatchScoreType) -> String {
        let team = fixedTeam ?? selectedTeam
        let event = MatchEvent(minute: 0, teamName: team, type: .tryScore(points: scoreType.points),
                               description: scoreType.description)
        guard let scorer else { return String(appLocalized: "\(event.localizedDescription) for \(team)") }
        return String(appLocalized: "\(event.localizedDescription) for \(team), number \(scorer)")
    }
}

#Preview {
    WatchScorePageView(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", homeScore: 12, awayScore: 7) {
        _, _, _, _ in
    }
}
