import SwiftUI

/// Shown for a few seconds after a score or card: takes it back (wrong team, number or tap).
struct WatchUndoLastWidget: View {
    let lastEntry: MatchEvent?
    let onUndo: () -> Void

    var body: some View {
        if let lastEntry, lastEntry.canUndo() {
            // Re-checks every second so the button goes away when the undo window closes.
            TimelineView(.periodic(from: .now, by: 1)) { context in
                if lastEntry.canUndo(at: context.date) {
                    button(for: lastEntry)
                }
            }
        }
    }

    private func button(for entry: MatchEvent) -> some View {
        Button(action: onUndo) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 22, height: 22)
                    .background(Color.iceTitanium.opacity(0.15), in: Circle())
                VStack(alignment: .leading, spacing: 0) {
                    Text("UNDO LAST ENTRY")
                        .font(.system(size: 11, weight: .heavy).width(.condensed))
                    Text(verbatim: "\(entry.localizedDescription) · \(entry.teamName)")
                        .font(.system(size: 8, weight: .semibold))
                        .lineLimit(1)
                        .opacity(0.8)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .foregroundStyle(Color.sinBinAmber)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.sinBinAmber.opacity(0.6)))
        }
        .buttonStyle(WatchTapLockButtonStyle())
        .accessibilityLabel("Undo \(entry.localizedDescription), \(entry.teamName)")
    }
}

#Preview {
    WatchUndoLastWidget(
        lastEntry: MatchEvent(minute: 12, teamName: "Rangers RFC", playerNumber: 9, type: .tryScore(points: 5),
                              description: "Try scored (+5)", recordedAt: Date()),
        onUndo: {}
    )
    .padding()
    .background(Color.pitchVoid)
}
