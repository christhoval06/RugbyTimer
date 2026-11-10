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

    /// When on, the Watch runs the coin toss before kick-off (the Setup "Coin toss" toggle).
    @Published public var coinTossEnabled: Bool = false
    /// Length of the half-time interval, counted down on the Watch from the half-time whistle.
    @Published public var halfTimeBreakSeconds: Int = 120
    /// When the half-time whistle went; nil outside the break.
    @Published public internal(set) var halfTimeStartedAt: Date?
    /// The coin toss done on the Watch for this match; nil until it happens.
    @Published public var coinToss: CoinTossResult?

    public var playerNumbers: ClosedRange<Int> { 1...max(1, maxPlayerNumber) }

    // Match Live Data
    @Published public var homeScore: Int = 0
    @Published public var awayScore: Int = 0
    @Published public var activeCards: [MatchCard] = []
    public var matchDurationText: String {
        let totalSeconds = matchDurationSeconds * 2
        return String(format: "%d:%02d Total", totalSeconds / 60, totalSeconds % 60) // l10n-ignore: unused
    }

    @Published public var matchEvents: [MatchEvent] = []

    @Published public var matchPeriod: MatchPeriod = .preMatch

    // Services
    public let connectivityService = WatchConnectivityService()
    public let timerService: MatchTimerService

    var subscriptions = Set<AnyCancellable>()
    var matchID: UUID?
    var lastWatchUpdate: Date?
    /// When the last Watch update was sent; drives the "Watch link lost" warning.
    @Published public internal(set) var lastWatchSyncAt: Date?
    // Sin-bins as the Watch last reported them, at the Watch clock reading of that report.
    var mirroredCards: [MatchCard] = []
    var mirroredClock = 0
    var rejectedConfigurationID: UUID?
    var lastClockReading: Int

    public var hasConfiguredMatch: Bool { matchID != nil }

    /// True when the iPhone itself runs the match (no Apple Watch): the phone owns the clock,
    /// scores and cards instead of mirroring Watch snapshots.
    @Published public internal(set) var isPhoneHosted = false

    /// Whether this device runs the match clock: always on Watch, and on iPhone only in iPhone-only mode.
    var runsClockLocally: Bool {
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
}
