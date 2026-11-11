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
    @StateObject private var appState = LaunchOptions.makeAppState()
    @StateObject private var settings = LaunchOptions.makeSettings()
    @StateObject private var history = LaunchOptions.makeHistory()
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingSplash = !SplashOverlay.isSkipped

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
                        halfTimeBreakSeconds: $appState.halfTimeBreakSeconds,
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
                        onReturnToSetup: { appState.returnToSetup() },
                        phoneControls: appState.isPhoneHosted ? appState.phoneControls : nil,
                        watchLink: appState.watchLinkStatus,
                        injuryTimers: appState.injuryTimers,
                        offFieldActions: appState.isPhoneHosted ? appState.offFieldActions : nil,
                        periodDuration: appState.currentPeriodSeconds
                    )

                }
            }
            .splashOverlay(isPresented: $isShowingSplash)
            .environmentObject(settings)
            .environmentObject(history)
            .environment(\.locale, settings.language.locale)
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: showsOnboarding) {
                OnboardingView { settings.hasCompletedOnboarding = true }
                    .environment(\.locale, settings.language.locale)
                    .preferredColorScheme(.dark)
            }
            .modifier(SettingsSyncModifier(appState: appState, settings: settings))
            .modifier(MatchHistoryRecorder(appState: appState, history: history))
            .modifier(MatchLiveActivityModifier(appState: appState))
            .environment(\.playerNumberRange, appState.playerNumbers)
            .environment(\.substitutionRules, appState.substitutionRules)
            .onChange(of: keepsScreenAwake, initial: true) { _, awake in
                UIApplication.shared.isIdleTimerDisabled = awake
            }
            // In iPhone-only mode the clock comes from a wall-clock end date; catch up after the app was in the background.
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { appState.timerService.refresh() } else { appState.saveMatch() }
            }
        }
    }

    private var showsOnboarding: Binding<Bool> {
        Binding(
            // Onboarding waits for the splash, so it doesn't cover it on first launch.
            get: { !settings.hasCompletedOnboarding && !isShowingSplash },
            set: { if !$0 { settings.hasCompletedOnboarding = true } }
        )
    }

    private var keepsScreenAwake: Bool {
        settings.keepScreenAwake && appState.currentScreen != .setup
    }

}
