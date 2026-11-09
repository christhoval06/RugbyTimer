//
//  AppState.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation
import Combine

public enum AppScreen: Equatable {
    case setup
    case liveMatch
    case summary
}

public class AppState: ObservableObject {
    @Published public var currentScreen: AppScreen = .setup

    // Match Configuration Data
    @Published public var homeTeamName: String = "Rangers RFC"
    @Published public var awayTeamName: String = "City Lions"
    @Published public var matchDurationSeconds: Int = 2400 // 40 mins default
    @Published public var sinBinDurationSeconds: Int = 600
    @Published public var maxPlayerNumber: Int = MatchEvent.playerNumbers.upperBound

    /// Watch scoring, cards and ending a half need a press-and-hold instead of a tap.
    @Published public var tapLockEnabled: Bool = true

    public var playerNumbers: ClosedRange<Int> { 1...max(1, maxPlayerNumber) }

    // Match Live Data
    @Published public var homeScore: Int = 0
    @Published public var awayScore: Int = 0
    @Published public var activeCards: [MatchCard] = []
    public var matchDurationText: String {
        let totalSeconds = matchDurationSeconds * 2
        return String(format: "%d:%02d Total", totalSeconds / 60, totalSeconds % 60)
    }

    @Published public var matchEvents: [MatchEvent] = []

    @Published public var matchPeriod: MatchPeriod = .preMatch

    // Services
    public let connectivityService = WatchConnectivityService()
    public let timerService: MatchTimerService

    private var subscriptions = Set<AnyCancellable>()
    private var matchID: UUID?
    private var lastWatchUpdate: Date?
    /// When the last Watch update was sent; drives the "Watch link lost" warning.
    @Published public private(set) var lastWatchSyncAt: Date?
    // Sin-bins as the Watch last reported them, at the Watch clock reading of that report.
    private var mirroredCards: [MatchCard] = []
    private var mirroredClock = 0
    private var rejectedConfigurationID: UUID?
    private var lastClockReading: Int

    public var hasConfiguredMatch: Bool { matchID != nil }

    /// True when the iPhone itself runs the match (no Apple Watch): the phone owns the clock,
    /// scores and cards instead of mirroring Watch snapshots.
    @Published public private(set) var isPhoneHosted = false

    /// Whether this device runs the match clock: always on Watch, and on iPhone only in iPhone-only mode.
    private var runsClockLocally: Bool {
        #if os(watchOS)
        return true
        #else
        return isPhoneHosted
        #endif
    }

    public init(timerService: MatchTimerService = MatchTimerService()) {
        self.timerService = timerService
        self.lastClockReading = timerService.clockSeconds
        connectivityService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &subscriptions)
        timerService.$clockSeconds.dropFirst().receive(on: RunLoop.main)
            .sink { [weak self] clock in
                guard let self else { return }
                guard self.runsClockLocally else { self.mirrorSinBins(to: clock); return }
                let previous = self.lastClockReading
                self.advanceSinBins(to: clock)
                if previous > 0 && clock <= 0 { self.handleTimeUp() }
                self.publishWatchSnapshot()
            }.store(in: &subscriptions)
        #if os(watchOS)
        connectivityService.$receivedConfiguration.compactMap { $0 }
            .sink { [weak self] in self?.receiveConfiguration($0) }
            .store(in: &subscriptions)
        timerService.$isRunning.dropFirst().receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.publishWatchSnapshot() }
            .store(in: &subscriptions)
        #else
        connectivityService.$receivedSnapshot.compactMap { $0 }
            .sink { [weak self] in self?.applyWatchSnapshot($0) }
            .store(in: &subscriptions)
        #endif
    }

    /// Sets up a new match. `onPhone: false` sends it to the Watch, which then runs the match;
    /// `onPhone: true` runs it on this iPhone (iPhone-only mode, for referees without a Watch).
    public func prepareMatch(onPhone: Bool = false) {
        guard matchPeriod == .preMatch || matchPeriod == .fullTime else { return }
        let id = UUID()
        matchID = id
        isPhoneHosted = onPhone
        resetMatchData()
        if onPhone {
            currentScreen = .liveMatch
            return
        }
        connectivityService.sendMatchConfig(MatchConfiguration(
            matchID: id, home: homeTeamName, away: awayTeamName, duration: matchDurationSeconds,
            sinBinDurationSeconds: sinBinDurationSeconds, maxPlayerNumber: maxPlayerNumber,
            tapLockEnabled: tapLockEnabled
        ))
        currentScreen = .liveMatch
    }

    // Keep the new setup and match identity while discarding the previous match.
    private func resetMatchData() {
        lastWatchUpdate = nil
        lastWatchSyncAt = nil
        rejectedConfigurationID = nil
        matchPeriod = .preMatch
        homeScore = 0
        awayScore = 0
        activeCards = []
        mirroredCards = []
        matchEvents = []
        timerService.reset(to: matchDurationSeconds)
    }

    public func startMatch() {
        guard runsClockLocally, matchPeriod == .preMatch, hasConfiguredMatch else { return }
        HapticService.playHalfTime()
        matchPeriod = .firstHalf
        timerService.reset(to: matchDurationSeconds)
        timerService.start()
        currentScreen = .liveMatch
        publishWatchSnapshot()
    }

    /// Pauses or resumes the match clock (iPhone-only mode; the Watch has its own control).
    public func toggleClock() {
        guard runsClockLocally, matchPeriod == .firstHalf || matchPeriod == .secondHalf else { return }
        HapticService.playStartStop()
        if timerService.isRunning { timerService.pause() } else { timerService.start() }
        publishWatchSnapshot()
    }

    private func receiveConfiguration(_ configuration: MatchConfiguration) {
        guard configuration.matchID != matchID else { return }
        guard matchPeriod == .preMatch || matchPeriod == .fullTime else {
            // A delayed setup cannot replace a match already started on Watch.
            rejectedConfigurationID = configuration.matchID
            publishWatchSnapshot()
            return
        }
        matchID = configuration.matchID
        homeTeamName = configuration.home
        awayTeamName = configuration.away
        matchDurationSeconds = configuration.duration
        sinBinDurationSeconds = configuration.sinBinDurationSeconds ?? 600
        maxPlayerNumber = configuration.maxPlayerNumber ?? MatchEvent.playerNumbers.upperBound
        tapLockEnabled = configuration.tapLockEnabled ?? false
        resetMatchData()
        publishWatchSnapshot()
    }

    public func applyWatchSnapshot(_ snapshot: MatchSnapshot) {
        #if !os(watchOS)
        // In iPhone-only mode the phone owns the match; a stale Watch must not overwrite it.
        guard !isPhoneHosted else { return }
        guard matchID == nil || matchID == snapshot.matchID || snapshot.rejectedConfigurationID == matchID else { return }
        if let lastWatchUpdate, snapshot.updatedAt <= lastWatchUpdate { return }
        lastWatchUpdate = snapshot.updatedAt
        // When the Watch sent it (capped at now, in case its clock runs ahead), so a report
        // delivered late still reads as old.
        let sentAt = min(snapshot.updatedAt, Date())
        lastWatchSyncAt = sentAt
        matchID = snapshot.matchID
        homeTeamName = snapshot.home
        awayTeamName = snapshot.away
        matchDurationSeconds = snapshot.duration
        sinBinDurationSeconds = snapshot.sinBinDurationSeconds ?? 600
        matchPeriod = snapshot.period
        homeScore = snapshot.homeScore
        awayScore = snapshot.awayScore
        activeCards = snapshot.cards
        mirroredCards = snapshot.cards
        mirroredClock = snapshot.remaining
        if let events = snapshot.events { matchEvents = events }
        // Older Watch builds send no end date; the send time plus the reading is within a second.
        let endDate = snapshot.clockEndDate
            ?? sentAt.addingTimeInterval(TimeInterval(snapshot.remaining))
        timerService.displayWatchTime(remaining: snapshot.remaining, isRunning: snapshot.isRunning, endDate: endDate)
        currentScreen = .liveMatch
        #endif
    }

    public func publishWatchSnapshot() {
        #if os(watchOS)
        guard let matchID else { return }
        connectivityService.sendMatchSnapshot(MatchSnapshot(
            matchID: matchID, home: homeTeamName, away: awayTeamName,
            duration: matchDurationSeconds, period: matchPeriod,
            remaining: timerService.clockSeconds, isRunning: timerService.isRunning,
            homeScore: homeScore, awayScore: awayScore, cards: activeCards,
            rejectedConfigurationID: rejectedConfigurationID,
            sinBinDurationSeconds: sinBinDurationSeconds,
            events: matchEvents,
            clockEndDate: timerService.endDate
        ))
        #endif
    }

    /// Time is up (the hooter): play continues into overtime until the referee ends the period.
    public func handleTimeUp() {
        guard matchPeriod == .firstHalf || matchPeriod == .secondHalf else { return }
        HapticService.playTimeUp()
    }

    /// Ends the current half when the referee blows the whistle (after time is up, or early).
    public func endPeriod() {
        handleTimerExpired()
        publishWatchSnapshot()
    }

    public func handleTimerExpired() {
        HapticService.playHalfTime()

        if matchPeriod == .firstHalf {
            matchPeriod = .halfTime
            timerService.pause()

            let htEvent = MatchEvent(
                minute: matchDurationSeconds / 60,
                teamName: "OFFICIAL",
                type: .sub,
                description: "HALF-TIME WHISTLE"
            )
            matchEvents.append(htEvent)

        } else if matchPeriod == .secondHalf {
            matchPeriod = .fullTime
            timerService.pause()
            currentScreen = .liveMatch

            let ftEvent = MatchEvent(
                minute: (matchDurationSeconds * 2) / 60,
                teamName: "OFFICIAL",
                type: .sub,
                description: "FULL-TIME WHISTLE"
            )
            matchEvents.append(ftEvent)
        }
    }

    /// Sin-bin time runs with the match clock, so it pauses when the clock pauses
    /// and catches up by the full gap after the app was suspended.
    private func advanceSinBins(to clock: Int) {
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
    private func mirrorSinBins(to clock: Int) {
        lastClockReading = clock
        let elapsed = mirroredClock - clock
        guard elapsed > 0, !mirroredCards.isEmpty else { return }
        activeCards = mirroredCards.map { card in
            var card = card
            card.tick(seconds: elapsed)
            return card
        }
    }

    public func startSecondHalf() {
        guard runsClockLocally, matchPeriod == .halfTime else { return }
        HapticService.playHalfTime()
        matchPeriod = .secondHalf
        timerService.reset(to: matchDurationSeconds)
        timerService.start()
        publishWatchSnapshot()
    }

    public func endMatch() {
        timerService.pause()
        matchPeriod = .fullTime
        currentScreen = .liveMatch
        publishWatchSnapshot()
    }

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
            description: "\(cardTitle) - #\(playerNum)"
        )
        matchEvents.append(event)
        publishWatchSnapshot()
    }


    public func incrementScore(forHome: Bool, points: Int) {
        if forHome {
            homeScore += points
        } else {
            awayScore += points
        }
    }

    private var currentMinute: Int {
        let elapsedSeconds = matchDurationSeconds - timerService.clockSeconds
        // Second-half events continue the match minute count (41', 42', ...) instead of restarting at 1'.
        let halfOffset = matchPeriod == .secondHalf ? matchDurationSeconds / 60 : 0
        return halfOffset + max(1, elapsedSeconds / 60)
    }

    /// `playerNumber` is optional: the referee may record points without naming the scorer.
    public func recordScore(team: String, playerNumber: Int? = nil, points: Int, description: String) {
        if team == homeTeamName {
            homeScore += points
        } else {
            awayScore += points
        }

        let event = MatchEvent(
            minute: currentMinute,
            teamName: team,
            playerNumber: playerNumber,
            type: .tryScore(points: points),
            description: description
        )
        matchEvents.append(event)
        publishWatchSnapshot()
    }


}
