//
//  AppState+TeamNames.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// Scores, cards and the team pickers tell the two sides apart by name, so the names must
    /// differ. Trims them, fills a blank one, and tags a repeated away name: "Lions (Away)".
    func makeTeamNamesDistinct() {
        let home = homeTeamName.trimmingCharacters(in: .whitespacesAndNewlines)
        let away = awayTeamName.trimmingCharacters(in: .whitespacesAndNewlines)
        homeTeamName = home.isEmpty ? String(appLocalized: "Home") : home
        awayTeamName = away.isEmpty ? String(appLocalized: "Away") : away
        if homeTeamName.compare(awayTeamName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame {
            awayTeamName = String(appLocalized: "\(awayTeamName) (Away)")
        }
    }
}
