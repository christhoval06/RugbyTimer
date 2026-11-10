import SwiftUI

/// A coin that spins and lands on `outcome`. `nil` shows heads, still, before the flip.
struct WatchCoinFlipWidget: View {
    let outcome: CoinFace?
    var size: CGFloat = 64
    var onLanded: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double = 0

    var body: some View {
        Color.clear
            .frame(width: size, height: size)
            .modifier(CoinSpinModifier(angle: angle, size: size))
            .onChange(of: outcome) { _, face in
                guard let face else { angle = 0; return }
                // Whole turns plus a half turn for tails; the spin ends on the right face.
                let target = Double(reduceMotion ? 0 : 6) * 360 + (face == .tails ? 180 : 0)
                withAnimation(reduceMotion ? nil : .easeOut(duration: 1.6)) {
                    angle = target
                } completion: {
                    onLanded()
                }
            }
            .accessibilityElement()
            .accessibilityLabel(Text(outcome == .tails ? "Tails" : "Heads"))
    }
}

/// Draws the face that is up for the current spin angle, so the coin changes face mid-spin.
private struct CoinSpinModifier: ViewModifier, Animatable {
    var angle: Double
    let size: CGFloat
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    private var showsTails: Bool {
        let turn = angle.truncatingRemainder(dividingBy: 360)
        return turn > 90 && turn < 270
    }

    func body(content: Content) -> some View {
        content.overlay {
            CoinFaceShape(face: showsTails ? .tails : .heads, size: size)
                // Mirror the back face so its text reads the right way round.
                .rotation3DEffect(.degrees(showsTails ? 180 : 0), axis: (x: 1, y: 0, z: 0))
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 1, y: 0, z: 0), perspective: 0.4)
    }
}

private struct CoinFaceShape: View {
    let face: CoinFace
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(face == .heads ? Color.sinBinAmber : Color.cardYellow)
            Circle().stroke(Color.pitchVoid.opacity(0.35), lineWidth: size * 0.045).padding(size * 0.06)
            VStack(spacing: 2) {
                Image(systemName: face == .heads ? "crown.fill" : "shield.lefthalf.filled")
                    .font(.system(size: size * 0.2, weight: .bold))
                Text(face == .heads ? "HEADS" : "TAILS")
                    .font(.system(size: size * 0.13, weight: .black).width(.condensed))
                    .tracking(1)
            }
            .foregroundStyle(Color.pitchVoid)
        }
    }
}

#Preview("Coin flip") {
    @Previewable @State var outcome: CoinFace?
    VStack(spacing: 12) {
        WatchCoinFlipWidget(outcome: outcome)
        Button("Flip") { outcome = outcome == nil ? .tails : nil }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.pitchVoid)
}
