import SwiftUI

struct WatchHalfTimeWidget: View {
    let onStartSecondHalf: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Text("BREAK")
                .font(.system(size: 20, weight: .black).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onStartSecondHalf) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 22, height: 22)
                        .background(Color.pitchVoid.opacity(0.12), in: Circle())
                    Text("KICK OFF H2")
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
                .background(Color.sinBinAmber, in: RoundedRectangle(cornerRadius: 11))
            }
            // Restarting the clock follows the Accidental tap lock like pause/resume.
            .buttonStyle(WatchTapLockButtonStyle())
            .accessibilityLabel("KICK OFF H2")
            .accessibilityHint("Starts the second-half match clock")
        }
    }
}
