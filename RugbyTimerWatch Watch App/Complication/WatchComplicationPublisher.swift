import Combine
import Foundation
import WidgetKit

/// Keeps the watch-face complication in step with the match: when the score, period, clock
/// state or sin-bins change, it saves a new snapshot to the App Group and reloads the widget.
/// The complication counts the clock down by itself, so ticks never trigger a reload.
final class WatchComplicationPublisher {
    private var subscriptions = Set<AnyCancellable>()
    private var lastSnapshot: ComplicationSnapshot?

    func attach(to appState: AppState) {
        subscriptions.removeAll()
        let cards = appState.$activeCards
            .map { $0.map { "\($0.id)\($0.isExpired)\($0.playerNumber)" } }
            .removeDuplicates()
            .map { _ in () }
        let scores = appState.$homeScore.combineLatest(appState.$awayScore).map { _ in () }
        let teams = appState.$homeTeamName.combineLatest(appState.$awayTeamName).map { _ in () }
        let clock = appState.timerService.$isRunning.combineLatest(appState.$matchPeriod, appState.$halfTimeStartedAt)
            .map { _ in () }

        Publishers.Merge4(cards, scores, teams, clock)
            // Published values change in willSet; let the change land and batch bursts of edits.
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self, weak appState] in
                guard let appState else { return }
                self?.publish(appState.complicationSnapshot)
            }
            .store(in: &subscriptions)
    }

    private func publish(_ snapshot: ComplicationSnapshot) {
        guard snapshot.differs(from: lastSnapshot) else { return }
        lastSnapshot = snapshot
        ComplicationStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private extension ComplicationSnapshot {
    /// Sin-bin end dates move by a fraction of a second between saves; ignore that jitter.
    func differs(from other: ComplicationSnapshot?) -> Bool {
        guard var other else { return true }
        if let mine = nextSinBinEndsAt, let theirs = other.nextSinBinEndsAt, abs(mine.timeIntervalSince(theirs)) < 2 {
            other.nextSinBinEndsAt = mine
        }
        return self != other
    }
}
