import SwiftUI

struct LiveFooterWidget: View {
    let matchPeriod: MatchPeriod
    let homeTeamName: String
    let awayTeamName: String
    let onShowRecord: () -> Void
    let onReturnToSetup: (() -> Void)?
    var isRunning = false
    var phoneControls: LiveMatchControls?
    /// False in landscape, where the share button sits under the final result in the clock column.
    var showsShareRecord = true

    var body: some View {
        VStack(spacing: 10) {
            if let phoneControls {
                LivePhoneControlsWidget(matchPeriod: matchPeriod, isRunning: isRunning,
                                        homeTeamName: homeTeamName, awayTeamName: awayTeamName, controls: phoneControls)
            }
            if matchPeriod == .fullTime, showsShareRecord {
                LiveShareRecordWidget(onShowRecord: onShowRecord)
            }
            if matchPeriod == .preMatch || matchPeriod == .fullTime, let onReturnToSetup {
                LiveSetupButtonWidget(isProminent: matchPeriod == .preMatch && phoneControls == nil,
                                      onReturnToSetup: onReturnToSetup)
            }
            Label(phoneControls == nil ? "Clock, cards and score are controlled on Apple Watch" : "Match running on this iPhone",
                  systemImage: phoneControls == nil ? "lock.fill" : "iphone")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.outline)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity)
        .background(Color.pitchVoid)
        .overlay(alignment: .top) { Color.armorBorder.frame(height: 1) }
    }
}
