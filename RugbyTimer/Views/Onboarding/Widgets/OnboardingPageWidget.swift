import SwiftUI

struct OnboardingPageWidget: View {
    let page: OnboardingPage
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer(minLength: 0)
            OnboardingIconWidget(symbol: page.symbol, tint: page.tint, isActive: isActive)
            VStack(alignment: .leading, spacing: 10) {
                Text(page.eyebrow)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(2.5)
                    .foregroundStyle(page.tint)
                Text(page.title)
                    .font(.system(size: 40, weight: .black).width(.condensed))
                    .tracking(-0.5)
                    .lineSpacing(-4)
                    .foregroundStyle(Color.iceTitanium)
                    .minimumScaleFactor(0.7)
                    .accessibilityAddTraits(.isHeader)
            }
            .opacity(isActive ? 1 : 0)
            .offset(y: isActive ? 0 : 12)
            .animation(.easeOut(duration: 0.45).delay(0.1), value: isActive)
            OnboardingTypewriterTextWidget(text: String(appLocalized: page.description), isActive: isActive)
            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 560, alignment: .leading)
        .frame(maxWidth: .infinity)
    }
}
