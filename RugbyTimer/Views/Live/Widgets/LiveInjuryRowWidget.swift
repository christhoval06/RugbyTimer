import SwiftUI

/// An HIA or blood timer in the sanctions list, counted in real time.
struct LiveInjuryRowWidget: View {
    let injury: InjuryTimer

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = injury.remainingSeconds(at: context.date)
            HStack(spacing: 12) {
                SetupSettingLabelWidget(
                    symbol: injury.kind == .hia ? "brain.head.profile" : "drop.fill",
                    title: "#\(injury.playerNumber) · \(injury.teamName)",
                    subtitle: injury.kind == .hia ? "HIA · 12 min off-field assessment" : "Blood replacement · 15 min",
                    tint: Color.iceTitanium
                )
                Spacer(minLength: 4)
                let tint = remaining > 0 ? Color.iceTitanium : Color.expulsionRed
                Text(remaining > 0 ? Self.clock(remaining) : String(appLocalized: "TIME UP"))
                    .font(.system(size: 17, weight: .heavy, design: .monospaced))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 36)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(14)
            .accessibilityElement(children: .combine)
        }
    }

    static func clock(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    LiveInjuryRowWidget(injury: InjuryTimer(teamName: "City Lions", playerNumber: 12, kind: .hia))
        .background(Color.surfaceContainer)
        .preferredColorScheme(.dark)
}
