import SwiftUI

struct SetupWatchDisplayWidget: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Watch display settings")
                .font(.system(size: 13, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                Toggle("Extended layout", isOn: $settings.watchDisplayPreferences.extendedLayout)
                    .padding(14)
                Rectangle().fill(Color.armorBorder).frame(height: 1).padding(.horizontal, 14)
                Toggle("Show penalties and sanctions", isOn: $settings.watchDisplayPreferences.showDiscipline)
                    .padding(14)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.iceTitanium)
            .tint(Color.pitchEmerald)
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))

            Text("Applied when you send setup to the Watch.")
                .font(.system(size: 10))
                .foregroundStyle(Color.outline)
        }
    }
}

#Preview {
    SetupWatchDisplayWidget()
        .padding()
        .background(Color.pitchVoid)
        .environmentObject(AppSettings())
}
