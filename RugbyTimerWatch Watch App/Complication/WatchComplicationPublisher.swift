import Combine
import Foundation
import WidgetKit

/// Keeps the watch-face complication in step with the match: each new glance is saved to the
/// App Group and the widget reloads. The complication counts the clock itself between reloads.
final class WatchComplicationPublisher {
    private var subscription: AnyCancellable?

    func attach(to appState: AppState) {
        subscription = appState.glanceChanges.sink { glance in
            ComplicationStore.save(glance)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
