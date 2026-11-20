import Testing
@testable import RugbyTimerWatch_Watch_App

struct WatchMatchPageTests {
    @Test func extendedOrdersTeamActionsOutwardFromClock() {
        #expect(WatchMatchPage.extended(isPlaying: true, showsDiscipline: true, showsSubstitutions: true) == [
            .team(.away, .injuries), .team(.away, .substitutions), .team(.away, .sanctions),
            .team(.away, .penalties), .team(.away, .score), .clock,
            .team(.home, .score), .team(.home, .penalties), .team(.home, .sanctions),
            .team(.home, .substitutions), .team(.home, .injuries)
        ])
    }

    @Test func extendedSkipsDisabledPages() {
        #expect(WatchMatchPage.extended(isPlaying: true, showsDiscipline: false, showsSubstitutions: false) == [
            .team(.away, .injuries), .team(.away, .score), .clock,
            .team(.home, .score), .team(.home, .injuries)
        ])
    }

    @Test func substitutionsRemainAvailableWhenDisciplineIsHidden() {
        #expect(WatchMatchPage.extended(isPlaying: true, showsDiscipline: false, showsSubstitutions: true) == [
            .team(.away, .injuries), .team(.away, .substitutions), .team(.away, .score), .clock,
            .team(.home, .score), .team(.home, .substitutions), .team(.home, .injuries)
        ])
    }

    @Test func breakOffersTeamSubstitutionsWhenEnabled() {
        #expect(WatchMatchPage.extended(isPlaying: false, showsDiscipline: true, showsSubstitutions: true) == [
            .team(.away, .substitutions), .clock, .team(.home, .substitutions)
        ])
        #expect(WatchMatchPage.extended(isPlaying: false, showsDiscipline: true, showsSubstitutions: false) == [.clock])
    }
}
