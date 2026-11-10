import SwiftUI

struct SettingsAboutWidget: View {
    @ObservedObject var settings: AppSettings
    @State private var isShowingTour = false

    var body: some View {
        SettingsGroupWidget(number: "04", title: "ABOUT", detail: "THE APP & ITS MAKER") {
            Button {
                isShowingTour = true
            } label: {
                SettingsLinkRowWidget(symbol: "sparkles", title: "Know the app",
                                      subtitle: "Replay the welcome tour")
            }
            .accessibilityIdentifier("replayOnboarding")
            SettingsDividerWidget()
            NavigationLink {
                DeveloperView()
            } label: {
                SettingsLinkRowWidget(symbol: "person.crop.circle", title: "About the developer",
                                      subtitle: "\(AppInfo.developerName)", tint: .sinBinAmber)
            }
        }
        .fullScreenCover(isPresented: $isShowingTour) {
            OnboardingView { isShowingTour = false }
                .environment(\.locale, settings.language.locale)
                .preferredColorScheme(.dark)
        }
    }
}
