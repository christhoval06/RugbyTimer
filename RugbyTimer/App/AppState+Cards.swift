//
//  AppState+Cards.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    public func addCard(team: String, playerNum: Int, type: CardType) {
        let newCard = MatchCard(teamName: team, playerNumber: playerNum, type: type,
                                durationSeconds: type == .yellow ? sinBinDurationSeconds : 600)
        activeCards.append(newCard)

        let eventType: MatchEventType = (type == .yellow) ? .yellowCard : .redCard
        let cardTitle = (type == .yellow) ? "Yellow Card (Sin-Bin)" : "Red Card (Expulsion)"

        let event = MatchEvent(
            minute: currentMinute,
            teamName: team,
            playerNumber: playerNum,
            type: eventType,
            description: "\(cardTitle) - #\(playerNum)",
            matchSeconds: currentMatchSeconds
        )
        matchEvents.append(event)
        publishWatchSnapshot()
    }

    /// Sin-bin time runs with the match clock, so it pauses when the clock pauses
    /// and catches up by the full gap after the app was suspended.
    func advanceSinBins(to clock: Int) {
        defer { lastClockReading = clock }
        let elapsed = lastClockReading - clock
        guard elapsed > 0, !activeCards.isEmpty else { return }
        var didExpire = false
        for index in activeCards.indices {
            let wasExpired = activeCards[index].isExpired
            activeCards[index].tick(seconds: elapsed)
            if !wasExpired && activeCards[index].isExpired { didExpire = true }
        }
        if didExpire { HapticService.playSinBinExpired() }
    }

    /// iPhone mirror: counts the Watch's sin-bins down with the locally running clock, from the
    /// last report, so they stay right while the Watch is out of range. No haptics on the phone.
    func mirrorSinBins(to clock: Int) {
        lastClockReading = clock
        let elapsed = mirroredClock - clock
        guard elapsed > 0, !mirroredCards.isEmpty else { return }
        activeCards = mirroredCards.map { card in
            var card = card
            card.tick(seconds: elapsed)
            return card
        }
    }
}
