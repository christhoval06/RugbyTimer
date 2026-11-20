import SwiftUI

struct WatchLiveMatchView: View {
    typealias Page = WatchMatchPage

    let timerService: MatchTimerService
    let activeCards: [MatchCard]
    let homeTeamName: String
    let awayTeamName: String
    let matchPeriod: MatchPeriod
    let totalDuration: Int
    let homeScore: Int
    let awayScore: Int
    var matchEvents: [MatchEvent] = []
    var halfTimeBreakEndsAt: Date? = nil
    var halfTimeBreakSeconds = 120
    var twentyMinuteRedEnabled = false
    var injuryTimers: [InjuryTimer] = []
    /// End a sin-bin, fix a number, end an injury timer; nil keeps the lists read-only.
    var offFieldActions: OffFieldActions? = nil
    var onStartInjury: (InjuryKind, String, Int) -> Void = { _, _, _ in }
    let onAddCard: (String, Int, Sanction) -> Void
    let onScore: (String, Int?, Int, String) -> Void
    let onStartSecondHalf: () -> Void
    let onEndPeriod: () -> Void
    var onEndMatch: () -> Void = {}
    var onNewMatch: (() -> Void)? = nil
    var onUndo: () -> Void = {}
    var nextExtraPeriod: MatchPeriod? = nil
    var onStartExtraPeriod: () -> Void = {}
    var onConcede: (Infringement, String) -> Void = { _, _ in }
    var substitutionRules = SubstitutionRules()
    var onSubstitute: (String, Int, Int) -> Void = { _, _, _ in }

    @AppStorage(WatchDisplayPreferences.extendedLayoutKey) private var extendedLayout = false
    @AppStorage(WatchDisplayPreferences.showDisciplineKey) private var showDiscipline = true

    var showsDiscipline: Bool { showDiscipline }

    @State var page: Page = .clock
    @State var centerPage: WatchCenterPagesWidget.Page = .timers

    var isPlaying: Bool { matchPeriod.isPlaying }

    var body: some View {
        Group {
            if extendedLayout {
                extendedPages
            } else {
                compactPages
            }
        }
        .background(Color.pitchVoid.ignoresSafeArea())
        .onChange(of: matchPeriod, initial: true) {
            if case .team = page { page = .clock }
            if !isPlaying && [.score, .sanctions, .penalties].contains(page) { page = .clock }
            if !showsSubstitutions && page == .substitutions { page = .clock }
            centerPage = matchPeriod == .fullTime ? .results : .timers
        }
        .onChange(of: showDiscipline) {
            if [.sanctions, .penalties].contains(page) { page = .clock }
        }
        .onChange(of: extendedMatchPages) {
            if extendedLayout && !extendedMatchPages.contains(page) { page = .clock }
        }
        .onChange(of: extendedLayout) {
            page = .clock
            centerPage = matchPeriod == .fullTime ? .results : .timers
        }
    }

    func returnToMatch() {
        withAnimation {
            page = .clock
            centerPage = .timers
        }
    }
}
