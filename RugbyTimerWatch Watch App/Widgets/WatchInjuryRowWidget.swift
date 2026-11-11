import SwiftUI

/// An HIA or blood timer in the off-field list, counted in real time.
struct WatchInjuryRowWidget: View {
    let injury: InjuryTimer

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = injury.remainingSeconds(at: context.date)
            HStack(spacing: 6) {
                Image(systemName: injury.kind == .hia ? "brain.head.profile" : "drop.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.iceTitanium)
                    .frame(width: 8)
                Text("#\(injury.playerNumber)")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(Color.iceTitanium)
                Text(injury.teamName)
                    .font(.system(size: 10, weight: .semibold).width(.condensed))
                    .foregroundStyle(Color.outline)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(remaining > 0 ? Self.clock(remaining) : String(appLocalized: "TIME UP"))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(remaining > 0 ? Color.iceTitanium : Color.expulsionRed)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(injury.kind == .hia
                ? Text("HIA, number \(injury.playerNumber), \(injury.teamName), \(Self.clock(max(0, remaining)))")
                : Text("Blood replacement, number \(injury.playerNumber), \(injury.teamName), \(Self.clock(max(0, remaining)))"))
        }
    }

    static func clock(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    WatchInjuryRowWidget(injury: InjuryTimer(teamName: "City Lions", playerNumber: 12, kind: .hia))
        .padding()
}
