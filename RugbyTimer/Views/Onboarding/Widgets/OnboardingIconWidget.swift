import SwiftUI

struct OnboardingIconWidget: View {
    let symbol: String
    let tint: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.12), lineWidth: 1)
                .frame(width: 128, height: 128)
            Circle()
                .trim(from: 0, to: isActive ? 0.75 : 0)
                .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 128, height: 128)
                .animation(.easeOut(duration: 0.9), value: isActive)
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(tint)
                .symbolEffect(.bounce, value: isActive)
                .frame(width: 96, height: 96)
                .background(tint.opacity(0.08), in: Circle())
        }
        .accessibilityHidden(true)
    }
}
