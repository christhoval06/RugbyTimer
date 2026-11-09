import SwiftUI

struct LiveScoringWidget: View {
    let events: [MatchEvent]
    let homeTeamName: String

    private struct ScoringEntry: Identifiable {
        let event: MatchEvent
        let points: Int
        let isHome: Bool
        let runningScore: String
        var id: UUID { event.id }
    }

    /// Score events, newest first, each with the score line right after it.
    private var entries: [ScoringEntry] {
        var home = 0
        var away = 0
        var result: [ScoringEntry] = []
        for event in events {
            guard case let .tryScore(points) = event.type else { continue }
            let isHome = event.teamName == homeTeamName
            if isHome { home += points } else { away += points }
            result.append(ScoringEntry(event: event, points: points, isHome: isHome, runningScore: "\(home)–\(away)"))
        }
        return result.reversed()
    }

    var body: some View {
        let entries = entries
        VStack(spacing: 12) {
            SetupSectionHeadingWidget(number: "03", title: "SCORING", detail: "\(entries.count) EVENTS")
            VStack(spacing: 0) {
                if entries.isEmpty {
                    Label("No points scored yet", systemImage: "sportscourt")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.outline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                } else {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        if index > 0 {
                            Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                        }
                        LiveScoringRowWidget(
                            event: entry.event,
                            points: entry.points,
                            runningScore: entry.runningScore,
                            tint: entry.isHome ? Color.pitchEmerald : Color.sinBinAmber
                        )
                    }
                }
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }
}
