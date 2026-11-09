import SwiftUI

struct LiveScoreSheetWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let onScore: (String, Int?, Int, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeam: String
    @State private var scorer: Int?

    init(homeTeamName: String, awayTeamName: String, onScore: @escaping (String, Int?, Int, String) -> Void) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.onScore = onScore
        _selectedTeam = State(initialValue: homeTeamName)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    LiveSheetHeaderWidget(eyebrow: "POINTS", title: "RECORD SCORE", tint: Color.pitchEmerald) { dismiss() }

                    VStack(spacing: 12) {
                        SetupSectionHeadingWidget(number: "01", title: "TEAM", detail: "WHO SCORED")
                        LiveTeamPickerWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName, selectedTeam: $selectedTeam)
                    }

                    VStack(spacing: 12) {
                        SetupSectionHeadingWidget(number: "02", title: "SCORER", detail: scorer.map { "#\($0)" as LocalizedStringKey } ?? "OPTIONAL")
                        LivePlayerNumberGridWidget(selectedNumber: $scorer, tint: Color.pitchEmerald, allowsNone: true)
                    }
                }
                .padding(20)
            }

            VStack(spacing: 10) {
                SetupSectionHeadingWidget(number: "03", title: "TYPE", detail: "TAP TO RECORD")
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(LiveMatchControls.scoreTypes, id: \.id) { scoreType in
                        Button {
                            HapticService.playCardIssued()
                            onScore(selectedTeam, scorer, scoreType.points, scoreType.description)
                            dismiss()
                        } label: {
                            LiveScoreTypeTileWidget(points: scoreType.points, label: scoreType.label)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(Text(scoreType.label)), \(scoreType.points) points")
                        .accessibilityIdentifier("score\(scoreType.id)")
                    }
                }
            }
            .padding(20)
            .background(Color.pitchVoid)
            .overlay(alignment: .top) { Color.armorBorder.frame(height: 1) }
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }
}
