import SwiftUI

/// Launch splash shared by iPhone and Watch: app icon, name, tagline and a filling pitch-emerald bar.
struct SplashView: View {
    /// Smaller layout for the Watch screen.
    var compact = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRevealed = false
    @State private var progress: CGFloat = 0

    private var iconSize: CGFloat { compact ? 64 : 112 }
    private var barWidth: CGFloat { compact ? 72 : 140 }

    var body: some View {
        ZStack {
            Color.pitchVoid.ignoresSafeArea()
            VStack(spacing: compact ? 8 : 16) {
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .clipShape(RoundedRectangle(cornerRadius: iconSize * 0.22, style: .continuous))
                    .scaleEffect(isRevealed || reduceMotion ? 1 : 0.82)
                    .opacity(isRevealed ? 1 : 0)
                    .accessibilityHidden(true)
                VStack(spacing: compact ? 2 : 6) {
                    Text("RUGBY TIMER")
                        .font(.system(size: compact ? 16 : 28, weight: .heavy).width(.condensed))
                        .tracking(compact ? 1.5 : 3)
                        .foregroundStyle(Color.iceTitanium)
                    Text("MATCH CLOCK FOR REFEREES")
                        .font(.system(size: compact ? 8 : 11, weight: .bold, design: .monospaced))
                        .tracking(compact ? 0.8 : 2)
                        .foregroundStyle(Color.outline)
                        .multilineTextAlignment(.center)
                }
                .opacity(isRevealed ? 1 : 0)
                .offset(y: isRevealed || reduceMotion ? 0 : 8)
                progressBar
            }
            .padding(.horizontal, 16)
        }
        .accessibilityElement(children: .combine)
        .onAppear(perform: reveal)
    }

    private var progressBar: some View {
        Capsule()
            .fill(Color.armorBorder)
            .frame(width: barWidth, height: 3)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(Color.pitchEmerald)
                    .frame(width: barWidth * progress, height: 3)
            }
            .padding(.top, compact ? 4 : 10)
            .accessibilityHidden(true)
    }

    private func reveal() {
        withAnimation(reduceMotion ? .easeIn(duration: 0.2) : .spring(duration: 0.55, bounce: 0.25)) {
            isRevealed = true
        }
        withAnimation(.easeInOut(duration: SplashOverlay.displaySeconds - 0.2).delay(0.15)) {
            progress = 1
        }
    }
}

#Preview("iPhone splash") {
    SplashView()
        .preferredColorScheme(.dark)
}

#Preview("Watch splash (compact)") {
    SplashView(compact: true)
        .frame(width: 198, height: 242)
        .preferredColorScheme(.dark)
}
