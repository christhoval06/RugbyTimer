import SwiftUI

struct WatchKickoffHeaderWidget: View {
    let durationSeconds: Int

    var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Circle().fill(Color.pitchEmerald).frame(width: 3, height: 3)
                    Text("MATCH READY")
                        .font(.system(size: 7, weight: .bold))
                        .tracking(0.7)
                        .foregroundStyle(Color.pitchEmerald)
                }
                Text("KICKOFF")
                    .font(.system(size: 20, weight: .black).width(.condensed))
                    .foregroundStyle(Color.iceTitanium)
            }
            Spacer(minLength: 0)
            WatchHalfLengthWidget(durationSeconds: durationSeconds)
        }
    }
}
