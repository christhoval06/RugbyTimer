import SwiftUI

struct LiveScoreRowWidget: View {
    let title: LocalizedStringKey
    let name: String
    let score: Int
    let color: Color
    let isLeading: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPopping = false

    var body: some View {
        HStack(spacing: 13) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle().fill(color).frame(width: 6, height: 6)
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.7)
                        .foregroundStyle(color)
                    if isLeading {
                        Text("LEADING")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.outline)
                    }
                }
                Text(name)
                    .font(.system(size: 23, weight: .bold).width(.condensed))
                    .foregroundStyle(Color.iceTitanium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 8)
            Text("\(score)")
                .font(.system(size: 44, weight: .black).width(.condensed))
                .monospacedDigit()
                .foregroundStyle(isLeading ? color : Color.iceTitanium)
                // Digits roll up as points are added; the animation is what drives the transition.
                .contentTransition(.numericText(value: Double(score)))
                .scaleEffect(isPopping ? 1.18 : 1, anchor: .trailing)
                .animation(reduceMotion ? nil : .snappy(duration: 0.35), value: score)
        }
        .onChange(of: score) { old, new in
            guard new > old, !reduceMotion else { return }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { isPopping = true }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7).delay(0.2)) { isPopping = false }
        }
        .padding(16)
        .frame(minHeight: 94)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(score) points")
    }
}

#Preview("Score change animation") {
    @Previewable @State var score = 12
    VStack(spacing: 20) {
        LiveScoreRowWidget(title: "HOME", name: "Rangers RFC", score: score,
                           color: Color.pitchEmerald, isLeading: true)
        Button { score += 5 } label: { Text(verbatim: "TRY +5") }
            .buttonStyle(.borderedProminent)
            .tint(Color.pitchEmerald)
    }
    .padding(20)
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
