import SwiftUI

/// The toss on the Watch, step by step: who calls, the call, the flip, then the winner's
/// choice. "Physical coin" skips the flip when the referee tossed a real coin.
struct WatchCoinTossFlowWidget: View {
    let homeTeamName: String
    let awayTeamName: String
    var service = CoinTossService()
    let onComplete: (CoinTossResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isPhysical = false
    @State private var caller: TossSide?
    @State private var call: CoinFace?
    @State private var outcome: CoinFace?
    @State private var landed = false
    @State private var physicalWinner: TossSide?

    private var winner: TossSide? {
        if isPhysical { return physicalWinner }
        guard landed, let caller, let call, let outcome else { return nil }
        return call == outcome ? caller : caller.opponent
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchPageTitleWidget(eyebrow: isPhysical ? "PHYSICAL COIN" : "BEFORE KICK-OFF",
                                     title: "COIN TOSS", tint: .sinBinAmber)
                if !isPhysical && call != nil {
                    WatchCoinFlipWidget(outcome: outcome) {
                        HapticService.playCardIssued()
                        landed = true
                    }
                }
                step
            }
            .scenePadding(.horizontal)
        }
        .background(Color.pitchVoid.ignoresSafeArea())
        .animation(.snappy, value: caller)
        .animation(.snappy, value: landed)
        .animation(.snappy, value: physicalWinner)
    }

    @ViewBuilder private var step: some View {
        if let winner {
            prompt("\(name(winner)) WINS", tint: .pitchEmerald)
            WatchCoinTossOptionWidget(title: "KICK OFF", detail: "TAKES THE KICK-OFF") { finish(winner, .kickOff) }
            WatchCoinTossOptionWidget(title: "CHOOSE END", detail: "OPPONENT KICKS OFF") { finish(winner, .chooseEnd) }
        } else if isPhysical {
            prompt("WHO WON?")
            teamButtons { physicalWinner = $0 }
        } else if caller == nil {
            prompt("WHO CALLS?")
            teamButtons { caller = $0 }
            Button("PHYSICAL COIN") { isPhysical = true }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.outline)
                .buttonStyle(.plain)
                .padding(.top, 2)
        } else if call == nil {
            prompt("\(name(caller!)) CALLS")
            HStack(spacing: 6) {
                ForEach(CoinFace.allCases, id: \.self) { face in
                    WatchCoinTossOptionWidget(title: face == .heads ? "HEADS" : "TAILS") { flip(calling: face) }
                }
            }
        } else if !landed {
            prompt("IN THE AIR…", tint: .outline)
        }
    }

    private func prompt(_ text: LocalizedStringKey, tint: Color = .iceTitanium) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .black).width(.condensed))
            .foregroundStyle(tint)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
    }

    private func teamButtons(_ pick: @escaping (TossSide) -> Void) -> some View {
        VStack(spacing: 5) {
            WatchCoinTossOptionWidget(title: "\(homeTeamName)", detail: "HOME", tint: .pitchEmerald) { pick(.home) }
            WatchCoinTossOptionWidget(title: "\(awayTeamName)", detail: "AWAY", tint: .sinBinAmber) { pick(.away) }
        }
    }

    private func name(_ side: TossSide) -> String {
        (side == .home ? homeTeamName : awayTeamName).uppercased()
    }

    private func flip(calling face: CoinFace) {
        HapticService.playStartStop()
        call = face
        // Set after the coin appears so its spin animates from heads.
        DispatchQueue.main.async { outcome = service.flip() }
    }

    private func finish(_ winner: TossSide, _ choice: TossChoice) {
        HapticService.playStartStop()
        if !isPhysical, let caller, let call, let outcome {
            onComplete(CoinTossResult(caller: caller, call: call, outcome: outcome, choice: choice))
        } else {
            onComplete(.recorded(winner: winner, choice: choice))
        }
        dismiss()
    }
}

#Preview("Watch coin toss") {
    WatchCoinTossFlowWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions") { _ in }
}
