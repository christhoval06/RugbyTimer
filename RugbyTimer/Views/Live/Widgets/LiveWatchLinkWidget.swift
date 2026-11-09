import SwiftUI

/// Amber warning pinned above the iPhone mirror when the Watch stops reporting.
struct LiveWatchLinkWidget: View {
    let status: WatchLinkStatus

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            if status.isLost(at: context.date) {
                banner(secondsSinceSync: status.secondsSinceSync(at: context.date))
            }
        }
    }

    private func banner(secondsSinceSync: Int?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "applewatch.slash")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.sinBinAmber)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(secondsSinceSync == nil ? "WATCH NOT CONNECTED" : "WATCH LINK LOST")
                    .font(.system(size: 15, weight: .black).width(.condensed))
                    .tracking(1)
                    .foregroundStyle(Color.sinBinAmber)
                Text(message(secondsSinceSync: secondsSinceSync))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.iceTitanium)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.sinBinAmber.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.sinBinAmber.opacity(0.5)))
        .accessibilityElement(children: .combine)
    }

    private func message(secondsSinceSync: Int?) -> LocalizedStringKey {
        guard let seconds = secondsSinceSync else {
            return "Open RugbyTimer on the Watch. The setup arrives when it reconnects."
        }
        let ago = String(format: "%d:%02d", seconds / 60, seconds % 60)
        return "Last update \(ago) ago. The clock keeps counting here; scores and cards update when the Watch reconnects."
    }
}

#Preview("Watch link lost") {
    VStack(spacing: 16) {
        LiveWatchLinkWidget(status: WatchLinkStatus(
            isReachable: false, lastSyncAt: .now.addingTimeInterval(-42), isClockRunning: true
        ))
        LiveWatchLinkWidget(status: WatchLinkStatus(isReachable: false, lastSyncAt: nil, isClockRunning: false))
    }
    .padding(20)
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
