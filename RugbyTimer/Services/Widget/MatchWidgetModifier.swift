import SwiftUI

/// Attaches the Home Screen widget's publisher to the app's lifetime.
struct MatchWidgetModifier: ViewModifier {
    let appState: AppState
    let history: MatchHistory
    let settings: AppSettings
    @State private var publisher = MatchWidgetPublisher()

    func body(content: Content) -> some View {
        content.onAppear { publisher.attach(to: appState, history: history, settings: settings) }
    }
}
