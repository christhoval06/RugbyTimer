import SwiftUI

struct WatchReadyMatchWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let durationSeconds: Int
    let onStartMatch: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchKickoffHeaderWidget(durationSeconds: durationSeconds)
                WatchMatchupWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName
                )
                WatchKickoffButtonWidget(onStartMatch: onStartMatch)
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
        .background(Color.pitchVoid.ignoresSafeArea())
    }
}

#Preview("Ready for kickoff") {
    WatchReadyMatchWidget(
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        durationSeconds: 2400, onStartMatch: {}
    )
}
