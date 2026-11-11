import SwiftUI

/// iPhone-only mode: shown for a few seconds after a score or card so a mis-tap can be taken back.
struct LiveUndoLastWidget: View {
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
            HStack(spacing: 10) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 14, weight: .bold))
                VStack(alignment: .leading, spacing: 2) {
                    Text("UNDO LAST ENTRY")
                        .font(.system(size: 14, weight: .black).width(.condensed))
                        .tracking(0.5)
                    Text(verbatim: "\(entry.localizedDescription) · \(entry.teamName)")
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                        .opacity(0.8)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .foregroundStyle(Color.sinBinAmber)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color.sinBinAmber.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.sinBinAmber.opacity(0.35)))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("undoLastEntry")
        .accessibilityLabel("Undo \(entry.localizedDescription), \(entry.teamName)")
    }
}

#Preview {
    LiveUndoLastWidget(
        lastEntry: MatchEvent(minute: 12, teamName: "City Lions", playerNumber: 7, type: .yellowCard,
                              description: "Yellow Card (Sin-Bin) - #7", recordedAt: Date()),
        onUndo: {}
    )
    .padding()
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
