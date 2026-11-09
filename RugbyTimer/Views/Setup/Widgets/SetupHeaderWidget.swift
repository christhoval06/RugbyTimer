import SwiftUI

struct SetupHeaderWidget: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var isShowingSettings = false
    var isWatchAvailable = true

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("RUGBY TIMER")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(3)
                    .foregroundStyle(Color.pitchEmerald)
                Text("MATCH SETUP")
                    .font(.system(size: 32, weight: .black).width(.condensed))
                    .tracking(-0.5)
                    .foregroundStyle(Color.iceTitanium)
                Text(isWatchAvailable ? "Prepare on iPhone. Kick off on Watch." : "Set up and run the match on iPhone.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.outline)
            }
            Spacer(minLength: 0)
            Button {
                HapticService.playStartStop()
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Color.pitchEmerald)
                    .frame(width: 56, height: 56)
                    .background(Color.pitchEmerald.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.pitchEmerald.opacity(0.2)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("openSettings")
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .environmentObject(settings)
                .preferredColorScheme(.dark)
        }
    }

}
