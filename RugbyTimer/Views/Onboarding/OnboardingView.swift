import SwiftUI

struct OnboardingView: View {
    var pages = OnboardingPage.all
    let onFinish: () -> Void

    @State private var selection = 0

    var body: some View {
        VStack(spacing: 0) {
            OnboardingTopBarWidget(showsSkip: selection < pages.count - 1, onSkip: onFinish)
            TabView(selection: $selection) {
                ForEach(pages) { page in
                    OnboardingPageWidget(page: page, isActive: selection == page.id)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            OnboardingControlsWidget(
                pageCount: pages.count,
                selection: $selection,
                tint: pages[selection].tint,
                onFinish: onFinish
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
    }
}

#Preview("Onboarding") {
    OnboardingView(onFinish: {})
        .preferredColorScheme(.dark)
}
