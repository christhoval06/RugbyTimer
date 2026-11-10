//
//  LiveMatchView.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import SwiftUI

public struct LiveMatchView: View {
    @ObservedObject public var timerService: MatchTimerService
    public var activeCards: [MatchCard]
    public var matchEvents: [MatchEvent]
    public var homeTeamName: String
    public var awayTeamName: String
    public var totalDuration: Int
    public var homeScore: Int
    public var awayScore: Int
    public var matchPeriod: MatchPeriod

    public var onAddCard: (String, Int, CardType) -> Void
    public var onScoreTapped: () -> Void
    public var onStartSecondHalf: () -> Void
    public var onReturnToSetup: (() -> Void)?
    /// Non-nil in iPhone-only mode: the screen shows kick-off, clock, score and card controls.
    public var phoneControls: LiveMatchControls?
    /// Non-nil while mirroring a Watch: shows a warning once the Watch stops reporting.
    public var watchLink: WatchLinkStatus?

    public init(
        timerService: MatchTimerService,
        activeCards: [MatchCard],
        matchEvents: [MatchEvent] = [],
        homeTeamName: String = "Home",
        awayTeamName: String = "Away",
        matchPeriod: MatchPeriod = .firstHalf,
        totalDuration: Int = 2400,
        homeScore: Int = 0,
        awayScore: Int = 0,
        onAddCard: @escaping (String, Int, CardType) -> Void,
        onScoreTapped: @escaping () -> Void,
        onStartSecondHalf: @escaping () -> Void,
        onReturnToSetup: (() -> Void)? = nil,
        phoneControls: LiveMatchControls? = nil,
        watchLink: WatchLinkStatus? = nil
    ) {
        self.timerService = timerService
        self.activeCards = activeCards
        self.matchEvents = matchEvents
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.matchPeriod = matchPeriod
        self.totalDuration = totalDuration
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.onAddCard = onAddCard
        self.onScoreTapped = onScoreTapped
        self.onStartSecondHalf = onStartSecondHalf
        self.onReturnToSetup = onReturnToSetup
        self.phoneControls = phoneControls
        self.watchLink = watchLink
    }

    var isPlaying: Bool { matchPeriod == .firstHalf || matchPeriod == .secondHalf }

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State var shownRecord: MatchRecordSheetItem?
    var isPhoneHosted: Bool { phoneControls != nil }

    public var body: some View {
        Group {
            if verticalSizeClass == .compact {
                LiveLandscapeLayoutWidget { height in
                    if matchPeriod == .fullTime {
                        fullTimePanel
                    } else {
                        clock(ringScale: min(1, max(0.5, (height - 100) / 276)), showsHeading: false)
                    }
                } details: {
                    if let watchLink { LiveWatchLinkWidget(status: watchLink) }
                    periodStatus
                    matchDetails
                } footer: { footer(showsShareRecord: false) }
            } else {
                VStack(spacing: 0) {
                    if let watchLink {
                        LiveWatchLinkWidget(status: watchLink)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            .frame(maxWidth: 600)
                    }
                    LivePortraitLayoutWidget {
                        LiveHeaderWidget(isPlaying: isPlaying, isPhoneHosted: isPhoneHosted)
                        periodStatus
                        clock()
                        matchDetails
                    } footer: { footer() }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
        .sheet(item: $shownRecord) { shown in
            LiveMatchRecordSheetWidget(record: shown.text, subject: recordSubject, onDone: { shownRecord = nil })
        }
    }
}
