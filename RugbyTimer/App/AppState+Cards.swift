//
//  AppState+Cards.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    public func addCard(team: String, playerNum: Int, type: CardType) {
        issue(type == .yellow ? .yellow : .red, team: team, playerNum: playerNum)
    }

    /// True when this player already has a yellow card, so another one should be a red.
    public func hasYellow(team: String, playerNum: Int) -> Bool {
        MatchEvent.hasYellow(in: matchEvents, team: team, playerNumber: playerNum)
    }

    /// Shows a card. A second yellow is a red: a 20-minute red when that rule is on, and it ends
    /// the player's running sin-bin (kept on the event so undo can put it back).
    public func issue(_ sanction: Sanction, team: String, playerNum: Int) {
        let isTimedRed = sanction == .twentyMinuteRed || (sanction == .secondYellowRed && twentyMinuteRedEnabled)
        let newCard = MatchCard(teamName: team, playerNumber: playerNum, type: sanction.cardType,
                                durationSeconds: sanction == .yellow ? sinBinDurationSeconds : 600,
                                twentyMinuteRed: isTimedRed)
        var replaced: MatchCard?
        if sanction == .secondYellowRed, let index = activeCards.firstIndex(where: {
            $0.type == .yellow && !$0.isExpired && $0.teamName == team && $0.playerNumber == playerNum
        }) {
            replaced = activeCards.remove(at: index)
        }
        activeCards.append(newCard)

        matchEvents.append(MatchEvent(
            minute: currentMinute,
            teamName: team,
            playerNumber: playerNum,
            type: sanction == .yellow ? .yellowCard : .redCard,
            description: "\(Self.cardTitle(sanction, timedRed: isTimedRed)) - #\(playerNum)",
            matchSeconds: currentMatchSeconds,
            recordedAt: Date(),
            cardID: newCard.id,
            replacedCard: replaced
        ))
        publishWatchSnapshot()
    }

    /// English, like every synced description; `MatchEvent.localizedDescription` translates it.
    private static func cardTitle(_ sanction: Sanction, timedRed: Bool) -> String {
        if sanction == .yellow { return "Yellow Card (Sin-Bin)" }
        let red = timedRed ? MatchEvent.twentyMinuteRedPrefix + "Red Card" : "Red Card" // l10n-ignore: synced English
        return sanction == .secondYellowRed ? "\(red) \(MatchEvent.secondYellowMarker)"
            : timedRed ? red : "Red Card (Expulsion)"
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
