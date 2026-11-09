import SwiftUI

struct LiveShareRecordWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let makeRecord: () -> String

    /// The record travels with the sheet's item, so the sheet can never open on stale (empty) text.
    @State private var shownRecord: ShownRecord?

    var body: some View {
        Button {
            HapticService.playStartStop()
            shownRecord = ShownRecord(text: makeRecord())
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.system(size: 24, weight: .medium))
                VStack(alignment: .leading, spacing: 3) {
                    Text("SHARE MATCH RECORD")
                        .font(.system(size: 19, weight: .black).width(.condensed))
                    Text("SCORE · TIMELINE · DISCIPLINE")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .opacity(0.65)
                }
                Spacer(minLength: 0)
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 19, weight: .semibold))
            }
            .foregroundStyle(Color.pitchVoid)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 66)
            .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("shareMatchRecord")
        .sheet(item: $shownRecord) { shown in
            LiveMatchRecordSheetWidget(
                record: shown.text,
                subject: String(localized: "Match record: \(homeTeamName) vs \(awayTeamName)"),
                onDone: { shownRecord = nil }
            )
        }
    }
}

private struct ShownRecord: Identifiable {
    let id = UUID()
    let text: String
}
