import SwiftUI

struct LiveSetupButtonWidget: View {
    let isProminent: Bool
    let onReturnToSetup: () -> Void

    var body: some View {
        Button {
            HapticService.playStartStop()
            onReturnToSetup()
        } label: {
            if isProminent {
                HStack(spacing: 12) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 22, weight: .medium))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("MATCH SETUP")
                            .font(.system(size: 19, weight: .black).width(.condensed))
                        Text("EDIT TEAMS & FORMAT")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1)
                            .opacity(0.65)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 19, weight: .semibold))
                }
                .foregroundStyle(Color.pitchVoid)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, minHeight: 66)
                .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 13))
            } else {
                Label("NEW MATCH SETUP", systemImage: "arrow.uturn.backward")
                    .font(.system(size: 14, weight: .heavy).width(.condensed))
                    .tracking(0.6)
                    .foregroundStyle(Color.pitchEmerald)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
                    .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("returnToMatchSetup")
    }
}
