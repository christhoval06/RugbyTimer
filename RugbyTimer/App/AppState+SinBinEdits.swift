//
//  AppState+SinBinEdits.swift
//  RugbyTimer
//

import Foundation

/// Corrections to a card already shown: end its countdown early, or fix the shirt number.
extension AppState {
    /// The off-field list actions, for the device running the match.
    public var offFieldActions: OffFieldActions {
        OffFieldActions(
            endSinBin: { [weak self] in self?.endSinBinNow(cardID: $0) },
            fixNumber: { [weak self] in self?.correctPlayerNumber(cardID: $0, to: $1) },
            endInjury: { [weak self] in self?.endInjury(id: $0, outcome: $1) }
        )
    }

    /// Ends a sin-bin or 20-minute red countdown now (the referee's call, e.g. it was started late).
    public func endSinBinNow(cardID: UUID) {
        guard let index = activeCards.firstIndex(where: { $0.id == cardID }),
              activeCards[index].countsDown, !activeCards[index].isExpired else { return }
        activeCards[index].endNow()
        HapticService.playStartStop()
        publishWatchSnapshot()
    }

    /// Changes the shirt number on a card and on its entry in the match record.
    public func correctPlayerNumber(cardID: UUID, to number: Int) {
        guard let index = activeCards.firstIndex(where: { $0.id == cardID }),
              activeCards[index].playerNumber != number else { return }
        let oldNumber = activeCards[index].playerNumber
        activeCards[index].renumber(number)
        if let eventIndex = matchEvents.firstIndex(where: { $0.cardID == cardID }) {
            matchEvents[eventIndex] = matchEvents[eventIndex].renumbered(from: oldNumber, to: number)
        }
        HapticService.playStartStop()
        publishWatchSnapshot()
    }
}

extension MatchEvent {
    /// The same entry with a corrected shirt number, in its fields and its "- #N" description.
    func renumbered(from oldNumber: Int, to number: Int) -> MatchEvent {
        let suffix = " - #\(oldNumber)"
        let text = description.hasSuffix(suffix)
            ? String(description.dropLast(suffix.count)) + " - #\(number)"
            : description
        return MatchEvent(
            id: id, minute: minute, teamName: teamName, playerNumber: number, type: type,
            description: text, overtimeSeconds: overtimeSeconds, matchSeconds: matchSeconds,
            recordedAt: recordedAt, cardID: cardID, replacedCard: replacedCard
        )
    }
}
