import SwiftUI

/// Match controls for iPhone-only mode: kick off, pause/resume, end the half, score and cards.
struct LivePhoneControlsWidget: View {
    let matchPeriod: MatchPeriod
    let isRunning: Bool
    let homeTeamName: String
    let awayTeamName: String
    let controls: LiveMatchControls

    @State private var isScoring = false
    @State private var isCarding = false
    @State private var isRecordingInjury = false
    @State private var isConfirmingEnd = false

    private var endTitle: LocalizedStringKey { matchPeriod == .firstHalf ? "END FIRST HALF" : "END MATCH" }

    var body: some View {
        VStack(spacing: 10) {
            switch matchPeriod {
            case .preMatch:
                LiveKickOffButtonWidget(title: "KICK OFF", subtitle: "START THE FIRST HALF",
                                        identifier: "kickOffFirstHalf", action: controls.onKickOff)
            case .halfTime:
                LiveKickOffButtonWidget(title: "KICK OFF H2", subtitle: "START THE SECOND HALF",
                                        identifier: "kickOffSecondHalf", action: controls.onStartSecondHalf)
            case .firstHalf, .secondHalf:
                HStack(spacing: 10) {
                    LiveControlTileWidget(symbol: "plus.circle.fill", title: "SCORE", tint: Color.pitchEmerald,
                                          isFilled: true) { isScoring = true }
                    LiveControlTileWidget(symbol: "rectangle.portrait.fill", title: "CARD", tint: Color.cardYellow,
                                          isFilled: true) { isCarding = true }
                    LiveControlTileWidget(symbol: "cross.case.fill", title: "INJURY", tint: Color.iceTitanium) {
                        isRecordingInjury = true
                    }
                }
                HStack(spacing: 10) {
                    LiveControlTileWidget(symbol: isRunning ? "pause.fill" : "play.fill",
                                          title: isRunning ? "PAUSE" : "RESUME",
                                          tint: isRunning ? Color.sinBinAmber : Color.pitchEmerald,
                                          action: controls.onToggleClock)
                    LiveControlTileWidget(symbol: "flag.checkered", title: endTitle, tint: Color.expulsionRed) {
                        isConfirmingEnd = true
                    }
                }
                LiveUndoLastWidget(lastEntry: controls.lastEntry, onUndo: controls.onUndo)
            case .fullTime:
                EmptyView()
            }
        }
        .confirmationDialog(endTitle, isPresented: $isConfirmingEnd, titleVisibility: .visible) {
            Button(matchPeriod == .firstHalf ? "Blow for half-time" : "Blow for full time", role: .destructive) {
                controls.onEndPeriod()
            }
            Button("Keep playing", role: .cancel) {}
        } message: {
            Text("The clock stops and the half is recorded in the match record.")
        }
        .sheet(isPresented: $isScoring) {
            LiveScoreSheetWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName, onScore: controls.onScore)
        }
        .sheet(isPresented: $isRecordingInjury) {
            LiveInjurySheetWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName, onStart: controls.onInjury)
        }
        .sheet(isPresented: $isCarding) {
            LiveCardSheetWidget(homeTeamName: homeTeamName, awayTeamName: awayTeamName,
                                matchEvents: controls.matchEvents,
                                twentyMinuteRedEnabled: controls.twentyMinuteRedEnabled, onCard: controls.onCard)
        }
    }
}
