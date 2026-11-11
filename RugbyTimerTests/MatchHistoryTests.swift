//
//  MatchHistoryTests.swift
//  RugbyTimerTests
//

import Testing
import Foundation
@testable import RugbyTimer

/// The match history rules (saved once, kept up to date, deleted for good), on in-memory storage.
@MainActor
struct MatchHistoryTests {
    private let history = MatchHistory(
        storage: InMemoryMatchHistoryStorage(),
        recordedIDs: RecordedMatchIDs(defaults: UserDefaults(suiteName: "history-\(UUID().uuidString)")!)
    )

    static func finishedMatch(home: String = "Rangers RFC", homeScore: Int = 5, awayScore: Int = 0) -> FinishedMatch {
        let state = AppState()
        state.homeTeamName = home
        state.awayTeamName = "City Lions"
        state.prepareMatch(onPhone: true)
        state.startMatch()
        if homeScore > 0 { state.recordScore(team: home, points: homeScore, description: "Try scored (+5)") }
        state.endPeriod()
        state.startSecondHalf()
        if awayScore > 0 { state.recordScore(team: "City Lions", points: awayScore, description: "Penalty goal (+3)") }
        state.endPeriod()
        return state.finishedMatch!
    }

    @Test func noFinishedMatchBeforeFullTime() {
        let state = AppState()
        state.prepareMatch(onPhone: true)
        state.startMatch()
        #expect(state.finishedMatch == nil)
    }

    @Test func finishedMatchIsSavedOnceAndUpdated() {
        let match = Self.finishedMatch()
        #expect(match.source == .iPhone)
        history.save(match)
        history.save(match)
        #expect(history.entries.count == 1)

        var later = match
        later.awayScore = 3
        history.save(later)
        #expect(history.entries.count == 1)
        #expect(history.entries.first?.awayScore == 3)
        #expect(history.entries.first?.recordText.contains("Rangers RFC 5 – 3 City Lions") == true)
    }

    @Test func deletedMatchDoesNotComeBack() throws {
        let match = Self.finishedMatch()
        history.save(match)
        history.delete(try #require(history.entries.first))
        // The full-time screen reports the match again, e.g. after a relaunch.
        history.save(match)
        #expect(history.entries.isEmpty)
    }

    @Test func eachMatchGetsItsOwnEntry() {
        history.save(Self.finishedMatch(home: "Rangers RFC"))
        history.save(Self.finishedMatch(home: "Harbour XV"))
        #expect(history.entries.count == 2)
    }

    @Test func quickMatchSurvivesTheTripFromTheWatch() throws {
        var match = Self.finishedMatch()
        match.source = .quickMatch
        let decoded = try JSONDecoder().decode(FinishedMatch.self, from: JSONEncoder().encode(match))
        #expect(decoded == match)
        history.save(decoded)
        #expect(history.entries.first?.source == .quickMatch)
    }
}

/// The SwiftData storage itself: what goes in comes back out, newest first.
@MainActor
struct SwiftDataMatchHistoryStorageTests {
    private let storage = SwiftDataMatchHistoryStorage(inMemory: true)

    @Test func storesUpdatesAndDeletesMatches() {
        let older = MatchHistoryTests.finishedMatch(home: "Harbour XV")
        let newer = MatchHistoryTests.finishedMatch(home: "Rangers RFC", awayScore: 3)
        storage.insert(older, playedAt: Date(timeIntervalSinceNow: -86_400))
        storage.insert(newer, playedAt: Date())
        #expect(storage.loadAll().map(\.homeTeam) == ["Rangers RFC", "Harbour XV"])
        #expect(storage.loadAll().first?.events == newer.events)
        #expect(storage.contains(matchID: older.matchID))

        var corrected = older
        corrected.homeScore = 10
        storage.update(corrected)
        #expect(storage.loadAll().last?.homeScore == 10)

        storage.delete(matchID: older.matchID)
        #expect(!storage.contains(matchID: older.matchID))
        #expect(storage.loadAll().count == 1)
    }
}
