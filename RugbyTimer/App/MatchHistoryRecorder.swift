//
//  MatchHistoryRecorder.swift
//  RugbyTimer
//

import SwiftUI
import Combine

/// Puts every finished match into the history: one run on this iPhone, one mirrored from the
/// Watch (from its last update), and Watch Quick Matches the Watch sends at full time.
struct MatchHistoryRecorder: ViewModifier {
    @ObservedObject var appState: AppState
    let history: MatchHistory

    func body(content: Content) -> some View {
        content
            // `initial` also covers a match that reached full time while the app was closed.
            .onChange(of: appState.matchPeriod, initial: true) { recordIfFinished() }
            .onChange(of: appState.matchEvents) { recordIfFinished() }
            .onReceive(appState.connectivityService.$receivedFinishedMatch.compactMap { $0 }) { history.save($0) }
    }

    private func recordIfFinished() {
        guard let match = appState.finishedMatch else { return }
        history.save(match)
    }
}
