import SwiftUI

struct SetupHeaderWidget: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var history: MatchHistory
    @State private var isShowingSettings = false
    @State private var isShowingHistory = false
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
            HStack(spacing: 8) {
                SetupHeaderButtonWidget(symbol: "clock.arrow.circlepath", label: "Match History",
                                        identifier: "openHistory") { isShowingHistory = true }
                SetupHeaderButtonWidget(symbol: "gearshape", label: "Settings",
                                        identifier: "openSettings") { isShowingSettings = true }
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            MatchHistoryView()
                .environmentObject(history)
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .environmentObject(settings)
                .preferredColorScheme(.dark)
        }
    }

}
