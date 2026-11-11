import Combine
import Foundation

extension AppState {
    /// The glance, re-read when something it shows changes: the score, the period, the clock
    /// starting or stopping, a card, the teams. The clock counts on screen by itself, so ticks never fire it.
    var glanceChanges: AnyPublisher<MatchGlance, Never> {
        let cards = $activeCards
            .map { $0.map { "\($0.id)\($0.isExpired)\($0.playerNumber)" } }
            .removeDuplicates()
            .map { _ in () }
        let scores = $homeScore.combineLatest($awayScore).map { _ in () }
        let teams = $homeTeamName.combineLatest($awayTeamName).map { _ in () }
        let clock = timerService.$isRunning.combineLatest($matchPeriod, $halfTimeStartedAt).map { _ in () }

        return Publishers.Merge4(cards, scores, teams, clock)
            // Published values change in willSet; let the change land and batch bursts of edits.
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .compactMap { [weak self] in self?.matchGlance }
            .removeDuplicates { $0.isSameGlance(as: $1) }
            .eraseToAnyPublisher()
    }
}

nonisolated extension MatchGlance {
    /// End dates move by a fraction of a second between reads (and with each Watch update); ignore that jitter.
    func isSameGlance(as other: MatchGlance) -> Bool {
        var other = other
        other.nextSinBinEndsAt = Self.steady(other.nextSinBinEndsAt, nextSinBinEndsAt)
        other.clockEndsAt = Self.steady(other.clockEndsAt, clockEndsAt)
        if isRunning { other.clockSeconds = clockSeconds }
        return self == other
    }

    private static func steady(_ date: Date?, _ reference: Date?) -> Date? {
        guard let date, let reference, abs(date.timeIntervalSince(reference)) < 2 else { return date }
        return reference
    }
}
