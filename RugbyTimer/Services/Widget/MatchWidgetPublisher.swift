import Combine
import Foundation
import WidgetKit

/// Keeps the Home Screen widget in step with the app: when the match, the screen, the history or
/// the language changes, the new snapshot is saved to the App Group and the widget reloads.
/// The widget counts the clock itself, so unchanged pictures never spend a reload.
final class MatchWidgetPublisher {
    private var subscription: AnyCancellable?
    private var lastSaved: MatchWidgetSnapshot?

    func attach(to appState: AppState, history: MatchHistory, settings: AppSettings) {
        guard subscription == nil else { return }
        lastSaved = MatchWidgetStore.load()
        subscription = appState.glanceChanges
            .combineLatest(appState.$currentScreen.removeDuplicates(),
                           history.$entries.map(\.first).removeDuplicates(),
                           settings.$language.removeDuplicates())
            // Published values change in willSet; read them once the change has landed.
            .receive(on: RunLoop.main)
            .sink { [weak self, weak appState, weak history] _ in
                guard let appState, let history else { return }
                self?.publish(MatchWidgetSnapshot.make(glance: appState.matchGlance, period: appState.matchPeriod,
                                                       isMatchShown: appState.currentScreen != .setup,
                                                       lastMatch: history.entries.first))
            }
    }

    private func publish(_ snapshot: MatchWidgetSnapshot) {
        if let lastSaved, lastSaved.showsSame(as: snapshot),
           snapshot.liveMatch == nil || Date() < lastSaved.liveMatchExpiresAt { return }
        MatchWidgetStore.save(snapshot)
        lastSaved = snapshot
        WidgetCenter.shared.reloadTimelines(ofKind: MatchWidgetStore.kind)
    }
}
