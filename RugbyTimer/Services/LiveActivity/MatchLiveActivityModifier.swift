import SwiftUI

/// Attaches the match's Live Activity to the app's lifetime.
struct MatchLiveActivityModifier: ViewModifier {
    let appState: AppState
    let settings: AppSettings
    @State private var controller = MatchLiveActivityController()

    func body(content: Content) -> some View {
        content.onAppear { controller.attach(to: appState, settings: settings) }
    }
}
