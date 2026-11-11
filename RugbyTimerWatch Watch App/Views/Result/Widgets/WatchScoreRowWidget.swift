import SwiftUI

struct WatchScoreRowWidget: View {
    let name: String
    let role: LocalizedStringKey
    let score: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Capsule().fill(tint).frame(width: 3, height: 14)
            Text(name)
                .font(.system(size: 13, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(score, format: .number)
                .font(.system(size: 15, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
                .fixedSize()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Text(role)), \(name), \(score) points"))
    }
}
