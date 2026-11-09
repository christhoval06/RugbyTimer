import SwiftUI

struct LiveHeaderWidget: View {
    let isPlaying: Bool
    var isPhoneHosted = false

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("RUGBY TIMER")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(3)
                    .foregroundStyle(Color.pitchEmerald)
                Text("LIVE MATCH")
                    .font(.system(size: 32, weight: .black).width(.condensed))
                    .tracking(-0.5)
                    .foregroundStyle(Color.iceTitanium)
                Text(isPhoneHosted ? "Running on this iPhone." : "Mirroring the referee's Apple Watch.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.outline)
            }
            Spacer(minLength: 0)
            Image(systemName: isPlaying ? "stopwatch" : (isPhoneHosted ? "iphone" : "applewatch"))
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Color.pitchEmerald)
                .frame(width: 56, height: 56)
                .background(Color.pitchEmerald.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.pitchEmerald.opacity(0.2)))
                .accessibilityHidden(true)
        }
    }
}
