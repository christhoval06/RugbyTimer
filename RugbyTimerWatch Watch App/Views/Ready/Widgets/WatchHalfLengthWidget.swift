import SwiftUI

struct WatchHalfLengthWidget: View {
    let durationSeconds: Int

    var body: some View {
        VStack(spacing: 0) {
            Text("\(durationSeconds / 60)")
                .font(.system(size: 17, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
            Text("MIN / HALF")
                .font(.system(size: 6, weight: .bold))
                .foregroundStyle(Color.outline)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.armorBorder))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(durationSeconds / 60) minutes per half")
    }
}
