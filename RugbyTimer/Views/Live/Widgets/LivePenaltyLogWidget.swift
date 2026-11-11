import SwiftUI

/// Every penalty and free kick so far, newest first: match time, team and PEN or FK.
/// Shows the last few, with "Show all" for the rest, so the list never pushes the
/// sanctions and scoring sections off the screen.
struct LivePenaltyLogWidget: View {
    let events: [MatchEvent]
    let homeTeamName: String

    static let collapsedCount = 5
    @State private var showsAll = false

    private var entries: [(event: MatchEvent, kind: Infringement)] {
        events.reversed().compactMap { event in Infringement.of(event).map { (event, $0) } }
    }

    var body: some View {
        let entries = entries
        if !entries.isEmpty {
            VStack(spacing: 0) {
                ForEach(Array(entries.prefix(showsAll ? entries.count : Self.collapsedCount).enumerated()),
                        id: \.element.event.id) { index, entry in
                    if index > 0 {
                        Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                    }
                    row(entry.event, kind: entry.kind)
                }
                if entries.count > Self.collapsedCount {
                    Button {
                        withAnimation(.snappy) { showsAll.toggle() }
                    } label: {
                        Text(showsAll ? "SHOW LESS" : "SHOW ALL · \(entries.count)")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(0.6)
                            .foregroundStyle(Color.sinBinAmber)
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .top) { Color.armorBorder.frame(height: 1) }
                    .accessibilityIdentifier("penaltyLog.toggle")
                }
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }

    private func row(_ event: MatchEvent, kind: Infringement) -> some View {
        let tint = event.teamName == homeTeamName ? Color.pitchEmerald : Color.sinBinAmber
        return HStack(spacing: 10) {
            Text(event.clockLabel)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.outline)
                .frame(width: 52, alignment: .leading)
            Circle().fill(tint).frame(width: 7, height: 7)
            Text(event.teamName)
                .font(.system(size: 14, weight: .semibold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(kind == .penalty ? "PEN" : "FK")
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(kind == .penalty ? Color.pitchVoid : tint)
                .padding(.horizontal, 8)
                .frame(minHeight: 22)
                .background(kind == .penalty ? tint : tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kind == .penalty
            ? Text("\(event.clockLabel), penalty against \(event.teamName)")
            : Text("\(event.clockLabel), free kick against \(event.teamName)"))
    }
}

#Preview {
    LivePenaltyLogWidget(
        events: [
            MatchEvent(minute: 3, teamName: "City Lions", type: .sub, description: "Penalty conceded", matchSeconds: 191),
            MatchEvent(minute: 9, teamName: "Rangers RFC", type: .sub, description: "Free kick conceded", matchSeconds: 545)
        ],
        homeTeamName: "Rangers RFC"
    )
    .padding()
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
