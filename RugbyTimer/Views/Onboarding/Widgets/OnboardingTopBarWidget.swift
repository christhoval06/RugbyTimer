import SwiftUI

struct OnboardingTopBarWidget: View {
    let showsSkip: Bool
    let onSkip: () -> Void

    var body: some View {
        HStack {
            Text("RUGBY TIMER")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(3)
                .foregroundStyle(Color.pitchEmerald)
            Spacer()
            Button("SKIP", action: onSkip)
                .font(.system(size: 12, weight: .heavy).width(.condensed))
                .tracking(1)
                .foregroundStyle(Color.outline)
                .frame(minWidth: 44, minHeight: 44)
                .opacity(showsSkip ? 1 : 0)
                .disabled(!showsSkip)
                .accessibilityIdentifier("onboardingSkip")
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.2), value: showsSkip)
    }
}
