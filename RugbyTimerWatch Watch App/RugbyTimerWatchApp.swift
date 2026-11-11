import SwiftUI
import WatchKit

@main
public struct RugbyTimerWatchApp: App {
    @StateObject private var appState = AppState.launch()
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
                    WatchHomeView { appState.startQuickMatch($0) }
                } else if appState.matchPeriod == .preMatch {
                    WatchReadyMatchView(
                        homeTeamName: appState.homeTeamName,
                        awayTeamName: appState.awayTeamName,
                        durationSeconds: appState.matchDurationSeconds,
                        kickOffTeamName: appState.kickOffTeamName(for: .firstHalf),
                        needsCoinToss: appState.needsCoinToss,
                        onCoinToss: appState.coinTossEnabled ? { appState.recordCoinToss($0) } : nil,
                        onStartMatch: appState.startMatch,
                        leaveKind: appState.isWatchOnlyMatch ? .changeSetup : .quickMatchInstead,
                        onLeave: { appState.leaveMatch() }
                    )
                } else {
                    WatchLiveMatchView(
                        timerService: appState.timerService,
                        activeCards: appState.activeCards,
                        homeTeamName: appState.homeTeamName,
                        awayTeamName: appState.awayTeamName,
                        matchPeriod: appState.matchPeriod,
                        totalDuration: appState.currentPeriodSeconds,
                        homeScore: appState.homeScore,
                        awayScore: appState.awayScore,
                        matchEvents: appState.matchEvents,
                        halfTimeBreakEndsAt: appState.halfTimeBreakEndsAt,
                        halfTimeBreakSeconds: appState.halfTimeBreakSeconds,
                        twentyMinuteRedEnabled: appState.twentyMinuteRedEnabled,
                        injuryTimers: appState.injuryTimers,
                        offFieldActions: appState.offFieldActions,
                        onStartInjury: { appState.startInjury($0, team: $1, playerNum: $2) },
                        onAddCard: { appState.issue($2, team: $0, playerNum: $1) },
                        onScore: { appState.recordScore(team: $0, playerNumber: $1, points: $2, description: $3) },
                        onStartSecondHalf: appState.startSecondHalf,
                        onEndPeriod: appState.endPeriod,
                        onEndMatch: appState.endMatch,
                        onNewMatch: newMatchAction,
                        onUndo: { appState.undoLastEntry() },
                        nextExtraPeriod: appState.nextExtraPeriod,
                        onStartExtraPeriod: appState.startExtraPeriod,
                        onConcede: { appState.concede($0, team: $1) }
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
                if phase == .active { runtime.appDidBecomeActive() } else { appState.saveMatch() }
            }
        }
    }

    /// NEW MATCH at full time: back to the main screen for the next match.
    private var newMatchAction: (() -> Void)? {
        guard appState.matchPeriod == .fullTime else { return nil }
        return { appState.leaveMatch() }
    }
}
