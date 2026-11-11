import SwiftUI

/// Ends an HIA or blood timer: the player is back on, or the replacement is permanent.
struct WatchInjuryActionsWidget: View {
    let injury: InjuryTimer
    let actions: OffFieldActions

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                WatchPageTitleWidget(eyebrow: injury.kind == .hia ? "HIA" : "BLOOD",
                                     title: "#\(injury.playerNumber)", tint: .iceTitanium)
                WatchInjuryRowWidget(injury: injury)
                WatchSanctionButtonWidget(
                    title: "BACK ON", tint: .pitchEmerald, textColor: .pitchVoid, showsCard: false,
                    accessibilityLabel: Text("The player is back on")
                ) { end(.returned) }
                WatchSanctionButtonWidget(
                    title: "REPLACED", tint: .expulsionRed, textColor: .iceTitanium, showsCard: false,
                    accessibilityLabel: Text("The replacement is permanent")
                ) { end(.replaced) }
            }
            .scenePadding(.horizontal)
        }
    }

    private func end(_ outcome: InjuryOutcome) {
        actions.endInjury(injury.id, outcome)
        dismiss()
    }
}

#Preview {
    WatchInjuryActionsWidget(injury: InjuryTimer(teamName: "City Lions", playerNumber: 12, kind: .hia),
                             actions: .preview)
}
