import SwiftUI
import WatchKit

@main
public struct RugbyTimerWatchApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var runtime = WatchMatchRuntime()
    @Environment(\.scenePhase) private var scenePhase

    public init() {
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
    }

    public var body: some Scene {
        WindowGroup {
            NavigationStack {
                if !appState.hasConfiguredMatch {
                    WatchSetupRequiredWidget()
                } else if appState.matchPeriod == .preMatch {
                    WatchReadyMatchWidget(
                        homeTeamName: appState.homeTeamName,
                        awayTeamName: appState.awayTeamName,
                        durationSeconds: appState.matchDurationSeconds,
                        onStartMatch: appState.startMatch
                    )
                } else {
                    WatchLiveMatchWidget(
                        timerService: appState.timerService,
                        activeCards: appState.activeCards,
                        homeTeamName: appState.homeTeamName,
                        awayTeamName: appState.awayTeamName,
                        matchPeriod: appState.matchPeriod,
                        totalDuration: appState.matchDurationSeconds,
                        homeScore: appState.homeScore,
                        awayScore: appState.awayScore,
                        matchEvents: appState.matchEvents,
                        onAddCard: { appState.addCard(team: $0, playerNum: $1, type: $2) },
                        onScore: { appState.recordScore(team: $0, playerNumber: $1, points: $2, description: $3) },
                        onStartSecondHalf: appState.startSecondHalf,
                        onEndPeriod: appState.endPeriod
                    )
                }
            }
            .environment(\.playerNumberRange, appState.playerNumbers)
            .environment(\.tapLockEnabled, appState.tapLockEnabled)
            .onAppear {
                runtime.attach(to: appState)
                let device = WKInterfaceDevice.current()
                appState.connectivityService.sendWatchTelemetry(
                    watchName: device.name,
                    battery: max(0, Int(device.batteryLevel * 100))
                )
                appState.publishWatchSnapshot()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { runtime.appDidBecomeActive() }
            }
        }
    }
}
