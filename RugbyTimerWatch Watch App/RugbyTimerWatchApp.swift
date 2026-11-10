import SwiftUI
import WatchKit

@main
public struct RugbyTimerWatchApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var runtime = WatchMatchRuntime()
    @Environment(\.scenePhase) private var scenePhase
    /// Set by the iPhone (Settings › Language); `system` follows the Watch's own language.
    @AppStorage(AppLanguage.defaultsKey) private var languageCode = AppLanguage.system.rawValue
    @State private var isShowingSplash = !SplashOverlay.isSkipped

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
                        kickOffTeamName: appState.kickOffTeamName(for: .firstHalf),
                        needsCoinToss: appState.needsCoinToss,
                        onCoinToss: appState.coinTossEnabled ? { appState.recordCoinToss($0) } : nil,
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
                        halfTimeBreakEndsAt: appState.halfTimeBreakEndsAt,
                        halfTimeBreakSeconds: appState.halfTimeBreakSeconds,
                        onAddCard: { appState.addCard(team: $0, playerNum: $1, type: $2) },
                        onScore: { appState.recordScore(team: $0, playerNumber: $1, points: $2, description: $3) },
                        onStartSecondHalf: appState.startSecondHalf,
                        onEndPeriod: appState.endPeriod,
                        onEndMatch: appState.endMatch
                    )
                }
            }
            .splashOverlay(isPresented: $isShowingSplash, compact: true)
            .environment(\.playerNumberRange, appState.playerNumbers)
            .environment(\.tapLockEnabled, appState.tapLockEnabled)
            .environment(\.locale, (AppLanguage(rawValue: languageCode) ?? .system).locale)
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
