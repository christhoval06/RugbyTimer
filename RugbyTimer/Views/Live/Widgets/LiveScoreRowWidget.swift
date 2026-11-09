import SwiftUI

struct LiveScoreRowWidget: View {
    let title: LocalizedStringKey
    let name: String
    let score: Int
    let color: Color
    let isLeading: Bool

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
                .contentTransition(.numericText())
        }
        .padding(16)
        .frame(minHeight: 94)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(score) points")
    }
}
