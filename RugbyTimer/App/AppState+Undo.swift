//
//  AppState+Undo.swift
//  RugbyTimer
//

import Foundation

public extension MatchEvent {
    /// How long after a score or card the referee can still take it back.
    static let undoWindow: TimeInterval = 15

    /// Scores and cards can be undone; whistles and the coin toss cannot.
    var isScoreOrCard: Bool {
        switch type {
        case .tryScore, .yellowCard, .redCard: true
        case .sub: false
        }
    }

    /// True for a score or card entered less than `undoWindow` ago.
    func canUndo(at now: Date = Date()) -> Bool {
        guard isScoreOrCard, let recordedAt else { return false }
        return now.timeIntervalSince(recordedAt) <= Self.undoWindow
    }
}

extension AppState {
    /// The latest entry, while it is a score or card that can still be undone.
    public func undoableEntry(at now: Date = Date()) -> MatchEvent? {
        guard matchPeriod == .firstHalf || matchPeriod == .secondHalf,
              let last = matchEvents.last, last.canUndo(at: now) else { return nil }
        return last
    }

    /// Takes back the latest score or card (wrong team, wrong number, mis-tap).
    public func undoLastEntry(at now: Date = Date()) {
        guard let entry = undoableEntry(at: now) else { return }
        removeEntry(entry)
    }

    /// Removes a score or card from the record and reverses what it did to the score or sin-bins.
    func removeEntry(_ entry: MatchEvent) {
        guard entry.isScoreOrCard, let index = matchEvents.firstIndex(where: { $0.id == entry.id }) else { return }
        switch entry.type {
        case .tryScore(let points):
            if entry.teamName == homeTeamName {
                homeScore = max(0, homeScore - points)
            } else {
                awayScore = max(0, awayScore - points)
            }
        case .yellowCard, .redCard:
            activeCards.removeAll { $0.id == entry.cardID }
            // A second-yellow red ended a running sin-bin; put it back.
            if let replaced = entry.replacedCard { activeCards.append(replaced) }
        case .sub:
            return
        }
        matchEvents.remove(at: index)
        HapticService.playStartStop()
        publishWatchSnapshot()
    }
}
