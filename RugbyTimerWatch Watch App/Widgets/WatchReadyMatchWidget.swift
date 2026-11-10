import SwiftUI

struct WatchReadyMatchWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    let durationSeconds: Int
    var kickOffTeamName: String? = nil
    /// Coin toss is on in Setup and has not happened yet: the toss replaces the start button.
    var needsCoinToss = false
    var onCoinToss: ((CoinTossResult) -> Void)? = nil
    let onStartMatch: () -> Void

    @State private var showsCoinToss = false

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchKickoffHeaderWidget(durationSeconds: durationSeconds)
                WatchMatchupWidget(
                    homeTeamName: homeTeamName,
                    awayTeamName: awayTeamName
                )
                if needsCoinToss {
                    WatchCoinTossButtonWidget { showsCoinToss = true }
                } else {
                    if let kickOffTeamName {
                        WatchKickOffTeamWidget(label: "KO", teamName: kickOffTeamName,
                                               onRedo: onCoinToss == nil ? nil : { showsCoinToss = true })
                    }
                    WatchKickoffButtonWidget(onStartMatch: onStartMatch)
                }
            }
            .padding(.vertical, 4)
            .scenePadding(.horizontal)
        }
        .background(Color.pitchVoid.ignoresSafeArea())
        .sheet(isPresented: $showsCoinToss) {
            WatchCoinTossFlowWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName) {
                onCoinToss?($0)
            }
        }
    }
}

#Preview("Ready for kickoff") {
    WatchReadyMatchWidget(
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        durationSeconds: 2400, kickOffTeamName: "City Lions", onStartMatch: {}
    )
}

#Preview("Coin toss first") {
    WatchReadyMatchWidget(
        homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
        durationSeconds: 2400, needsCoinToss: true, onCoinToss: { _ in }, onStartMatch: {}
    )
}
