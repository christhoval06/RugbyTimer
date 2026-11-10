//
//  RugbyTimerApp.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import SwiftUI
import UIKit

@main
public struct RugbyTimerApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var settings = AppSettings()
    @Environment(\.scenePhase) private var scenePhase

    public init() {}

    public var body: some Scene {
        WindowGroup {
            // ZStack (not Group) so the cover, tasks and observers attach once, not per screen.
            ZStack {
                switch appState.currentScreen {
                case .setup:
                    SetupView(
                        homeTeamName: $appState.homeTeamName,
                        awayTeamName: $appState.awayTeamName,
                        selectedDurationSeconds: $appState.matchDurationSeconds,
                        sinBinDurationSeconds: $appState.sinBinDurationSeconds,
                        isWatchSynced: appState.connectivityService.isWatchReachable,
                        watchName: appState.connectivityService.connectedWatchName,
                        watchBattery: appState.connectivityService.watchBatteryLevel,
                        isWatchAvailable: appState.connectivityService.isWatchAvailable,
                        onPrepareMatch: {
                            appState.prepareMatch()
                        },
                        onRunOnPhone: {
                            appState.prepareMatch(onPhone: true)
                        }
                    )

                case .liveMatch, .summary:
                    LiveMatchView(
                        timerService: appState.timerService,
                        activeCards: appState.activeCards,
                        matchEvents: appState.matchEvents,
                        homeTeamName: appState.homeTeamName,
                        awayTeamName: appState.awayTeamName,
                        matchPeriod: appState.matchPeriod,
                        totalDuration: appState.matchDurationSeconds,
                        homeScore: appState.homeScore,
                        awayScore: appState.awayScore,
                        onAddCard: { _, _, _ in },
                        onScoreTapped: {},
                        onStartSecondHalf: {},
                        onReturnToSetup: { appState.currentScreen = .setup },
                        phoneControls: appState.isPhoneHosted ? phoneControls : nil,
                        watchLink: appState.watchLinkStatus
                    )

                }
            }
            .environmentObject(settings)
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: showsOnboarding) {
                OnboardingView { settings.hasCompletedOnboarding = true }
                    .preferredColorScheme(.dark)
            }
            .task { applyAllDefaults() }
            .onChange(of: settings.defaultHalfSeconds) { _, value in applySetupDefault { appState.matchDurationSeconds = value } }
            .onChange(of: settings.defaultSinBinSeconds) { _, value in applySetupDefault { appState.sinBinDurationSeconds = value } }
            .onChange(of: settings.defaultHomeTeam) { _, value in applySetupDefault { appState.homeTeamName = value } }
            .onChange(of: settings.defaultAwayTeam) { _, value in applySetupDefault { appState.awayTeamName = value } }
            .onChange(of: settings.maxPlayerNumber, initial: true) { _, value in appState.maxPlayerNumber = value }
            .onChange(of: settings.tapLockEnabled, initial: true) { _, value in appState.tapLockEnabled = value }
            .onChange(of: settings.coinTossEnabled, initial: true) { _, value in appState.coinTossEnabled = value }
            .environment(\.playerNumberRange, appState.playerNumbers)
            .onChange(of: keepsScreenAwake, initial: true) { _, awake in
                UIApplication.shared.isIdleTimerDisabled = awake
            }
            // In iPhone-only mode the clock comes from a wall-clock end date; catch up after the app was in the background.
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { appState.timerService.refresh() }
            }
        }
    }

    private var phoneControls: LiveMatchControls {
        LiveMatchControls(
            onKickOff: { appState.startMatch() },
            onToggleClock: { appState.toggleClock() },
            onEndPeriod: { appState.endPeriod() },
            onStartSecondHalf: { appState.startSecondHalf() },
            onScore: { team, player, points, description in
                appState.recordScore(team: team, playerNumber: player, points: points, description: description)
            },
            onCard: { team, player, type in appState.addCard(team: team, playerNum: player, type: type) }
        )
    }

    private var showsOnboarding: Binding<Bool> {
        Binding(
            get: { !settings.hasCompletedOnboarding },
            set: { if !$0 { settings.hasCompletedOnboarding = true } }
        )
    }

    private var keepsScreenAwake: Bool {
        settings.keepScreenAwake && appState.currentScreen != .setup
    }

    private func applyAllDefaults() {
        guard !appState.hasConfiguredMatch else { return }
        appState.matchDurationSeconds = settings.defaultHalfSeconds
        appState.sinBinDurationSeconds = settings.defaultSinBinSeconds
        appState.homeTeamName = settings.defaultHomeTeam
        appState.awayTeamName = settings.defaultAwayTeam
    }

    /// Settings edits refresh the pending setup, never a match already in progress.
    private func applySetupDefault(_ apply: () -> Void) {
        guard appState.currentScreen == .setup else { return }
        apply()
    }
}

// MARK: - iPhone App Previews
#Preview("iPhone Flow - Setup Screen") {
    let state = AppState()
    state.currentScreen = .setup
    return SetupView(
        homeTeamName: .constant("Rangers RFC"),
        awayTeamName: .constant("City Lions"),
        selectedDurationSeconds: .constant(2400),
        sinBinDurationSeconds: .constant(600),
        isWatchSynced: true,
        watchName: "APPLE WATCH ULTRA",
        watchBattery: 98,
        onPrepareMatch: {}
    )
    .environmentObject(AppSettings())
    .preferredColorScheme(.dark)
}

#Preview("iPhone Flow - Live Match Screen") {
    let state = AppState()
    state.currentScreen = .liveMatch
    return LiveMatchView(
        timerService: state.timerService,
        activeCards: [
            MatchCard(teamName: "Rangers RFC", playerNumber: 8, type: .yellow, durationSeconds: 540)
        ],
        homeTeamName: state.homeTeamName,
        awayTeamName: state.awayTeamName,
        matchPeriod: .firstHalf,
        onAddCard: { _, _, _ in },
        onScoreTapped: {},
        onStartSecondHalf: {}
    )
    .preferredColorScheme(.dark)
}
