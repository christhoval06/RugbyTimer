import SwiftUI

/// Finished matches, newest first. Tap one to read and share its record; swipe to delete it.
struct MatchHistoryView: View {
    @EnvironmentObject private var history: MatchHistory
    @Environment(\.dismiss) private var dismiss

    @State private var shownEntry: MatchHistoryEntry?

    var body: some View {
        NavigationStack {
            Group {
                if history.entries.isEmpty {
                    MatchHistoryEmptyWidget()
                } else {
                    List {
                        ForEach(history.entries) { entry in
                            Button { shownEntry = entry } label: { MatchHistoryRowWidget(entry: entry) }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.surfaceContainer)
                                .accessibilityIdentifier("history.row")
                        }
                        .onDelete(perform: delete)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pitchVoid.ignoresSafeArea())
            .navigationTitle("Match History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("closeHistory")
                }
            }
        }
        .tint(Color.pitchEmerald)
        .sheet(item: $shownEntry) { entry in
            LiveMatchRecordSheetWidget(
                record: entry.recordText,
                subject: String(appLocalized: "Match record: \(entry.homeTeam) vs \(entry.awayTeam)"),
                onDone: { shownEntry = nil }
            )
        }
    }

    private func delete(_ offsets: IndexSet) {
        HapticService.playStartStop()
        let entries = offsets.map { history.entries[$0] }
        entries.forEach(history.delete)
    }
}

#Preview("Match history") {
    MatchHistoryView()
        .environmentObject(MatchHistory(storage: InMemoryMatchHistoryStorage([
            FinishedMatch(matchID: UUID(), home: "Rangers RFC", away: "City Lions", homeScore: 24, awayScore: 17,
                          halfSeconds: 2400, extraTimeFormat: .off, source: .watch, events: []),
            FinishedMatch(matchID: UUID(), home: "Team A", away: "Team B", homeScore: 12, awayScore: 12,
                          halfSeconds: 420, extraTimeFormat: .suddenDeath, source: .quickMatch, events: [])
        ]), recordedIDs: RecordedMatchIDs(defaults: UserDefaults(suiteName: "preview")!)))
        .preferredColorScheme(.dark)
}
