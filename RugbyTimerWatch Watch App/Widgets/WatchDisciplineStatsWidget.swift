import SwiftUI

/// Full-time discipline summary: yellow/red counts per team and the sanction log.
struct WatchDisciplineStatsWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let events: [MatchEvent]

    private var sanctions: [MatchEvent] {
        events.filter { $0.type == .yellowCard || $0.type == .redCard }
    }

    private func count(_ type: MatchEventType, team: String) -> Int {
        sanctions.filter { $0.type == type && $0.teamName == team }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("DISCIPLINE")
                    .font(.system(size: 9, weight: .heavy).width(.condensed))
                    .tracking(1)
                    .foregroundStyle(Color.cardYellow)
                Spacer(minLength: 0)
                Text(sanctions.isEmpty ? "CLEAN MATCH" : "\(sanctions.count) CARDS")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.outline)
            }

            WatchDisciplineTeamRowWidget(
                name: homeTeamName, tint: .pitchEmerald,
                yellow: count(.yellowCard, team: homeTeamName), red: count(.redCard, team: homeTeamName)
            )
            Rectangle().fill(Color.armorBorder).frame(height: 1)
                .accessibilityHidden(true)
            WatchDisciplineTeamRowWidget(
                name: awayTeamName, tint: .sinBinAmber,
                yellow: count(.yellowCard, team: awayTeamName), red: count(.redCard, team: awayTeamName)
            )

            if !sanctions.isEmpty {
                Rectangle().fill(Color.armorBorder).frame(height: 1)
                    .accessibilityHidden(true)
                ForEach(sanctions) { event in
                    WatchDisciplineLogRowWidget(
                        event: event,
                        tint: event.teamName == homeTeamName ? .pitchEmerald : .sinBinAmber
                    )
                }
            }
        }
        .padding(8)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
    }
}
