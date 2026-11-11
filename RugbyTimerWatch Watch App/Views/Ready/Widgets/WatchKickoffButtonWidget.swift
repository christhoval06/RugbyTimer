import SwiftUI

struct WatchKickoffButtonWidget: View {
    let onStartMatch: () -> Void

    var body: some View {
        Button(action: onStartMatch) {
            HStack(spacing: 6) {
                Image(systemName: "play.fill")
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 22, height: 22)
                    .background(Color.pitchVoid.opacity(0.12), in: Circle())
                Text("START MATCH")
                    .font(.system(size: 12, weight: .heavy).width(.condensed))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
            }
            .padding(.horizontal, 10)
            .foregroundStyle(Color.pitchVoid)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("START MATCH")
        .accessibilityHint("Starts the first-half match clock")
    }
}
