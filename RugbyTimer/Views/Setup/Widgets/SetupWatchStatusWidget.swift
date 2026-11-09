import SwiftUI

struct SetupWatchStatusWidget: View {
    let isWatchSynced: Bool
    let watchName: String
    let watchBattery: Int
    var isWatchAvailable = true

    private var title: LocalizedStringKey {
        if isWatchSynced { return "WATCH CONNECTED" }
        return isWatchAvailable ? "WAITING FOR APPLE WATCH" : "NO APPLE WATCH PAIRED"
    }

    private var detail: Text {
        if isWatchSynced { return Text(watchName) }
        return isWatchAvailable ? Text("Open RugbyTimer on your Watch") : Text("You can run the match on this iPhone")
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isWatchSynced || isWatchAvailable ? "applewatch" : "iphone")
                .font(.system(size: 24))
                .foregroundStyle(isWatchSynced ? Color.pitchEmerald : Color.outline)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Circle().fill(isWatchSynced ? Color.pitchEmerald : Color.sinBinAmber)
                        .frame(width: 5, height: 5)
                    Text(title)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(isWatchSynced ? Color.pitchEmerald : Color.sinBinAmber)
                }
                detail
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.outline)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if isWatchSynced {
                Label("\(watchBattery)%", systemImage: "battery.75percent")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.pitchEmerald)
            }
        }
        .padding(14)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.armorBorder))
        }

}
