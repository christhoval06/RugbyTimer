//
//  SettingsSyncModifier.swift
//  RugbyTimer
//

import SwiftUI

/// Keeps the match setup in step with Settings: defaults seed a new setup, and edits made in
/// Settings refresh the setup still on screen, never a match already in progress.
struct SettingsSyncModifier: ViewModifier {
    @ObservedObject var appState: AppState
    @ObservedObject var settings: AppSettings

    func body(content: Content) -> some View {
        content
            .onChange(of: settings.language, initial: true) { _, language in
                appState.connectivityService.sendAppLanguage(language)
            }
            .task { applyAllDefaults() }
            .onChange(of: settings.defaultHalfSeconds) { _, value in applySetupDefault { appState.matchDurationSeconds = value } }
            .onChange(of: settings.defaultSinBinSeconds) { _, value in applySetupDefault { appState.sinBinDurationSeconds = value } }
            .onChange(of: settings.defaultHomeTeam) { _, value in applySetupDefault { appState.homeTeamName = value } }
            .onChange(of: settings.defaultAwayTeam) { _, value in applySetupDefault { appState.awayTeamName = value } }
            .onChange(of: settings.maxPlayerNumber, initial: true) { _, value in appState.maxPlayerNumber = value }
            .onChange(of: settings.tapLockEnabled, initial: true) { _, value in appState.tapLockEnabled = value }
            .onChange(of: settings.halfTimeBreakSeconds) { _, value in applySetupDefault { appState.halfTimeBreakSeconds = value } }
            .onChange(of: settings.coinTossEnabled, initial: true) { _, value in appState.coinTossEnabled = value }
            .onChange(of: settings.twentyMinuteRedEnabled, initial: true) { _, value in
                applySetupDefault { appState.twentyMinuteRedEnabled = value }
            }
            .onChange(of: settings.extraTimeFormat, initial: true) { _, value in
                applySetupDefault { appState.extraTimeFormat = value }
            }
    }

    private func applyAllDefaults() {
        guard !appState.hasConfiguredMatch else { return }
        appState.matchDurationSeconds = settings.defaultHalfSeconds
        appState.sinBinDurationSeconds = settings.defaultSinBinSeconds
        appState.halfTimeBreakSeconds = settings.halfTimeBreakSeconds
        appState.homeTeamName = settings.defaultHomeTeam
        appState.awayTeamName = settings.defaultAwayTeam
    }

    /// Settings edits refresh the pending setup, never a match already in progress.
    private func applySetupDefault(_ apply: () -> Void) {
        guard appState.currentScreen == .setup else { return }
        apply()
    }
}
