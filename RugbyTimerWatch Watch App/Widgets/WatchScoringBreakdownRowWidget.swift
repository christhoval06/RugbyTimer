import SwiftUI

struct WatchScoringBreakdownRowWidget: View {
    static let columnWidth: CGFloat = 16

    let name: String
    let tint: Color
    let breakdown: ScoreBreakdown

    var body: some View {
        HStack(spacing: 0) {
            Circle().fill(tint).frame(width: 5, height: 5)
                .padding(.trailing, 5)
            Text(name)
                .font(.system(size: 12, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 2)
            count(breakdown.tries)
            count(breakdown.conversions)
            count(breakdown.penalties)
            count(breakdown.dropGoals)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(name): \(breakdown.tries) tries, \(breakdown.conversions) conversions, \(breakdown.penalties) penalty goals, \(breakdown.dropGoals) drop goals"))
    }

    private func count(_ value: Int) -> some View {
        Text("\(value)")
            .font(.system(size: 12, weight: .heavy, design: .monospaced))
            .foregroundStyle(value > 0 ? Color.iceTitanium : Color.outline.opacity(0.6))
            .frame(width: Self.columnWidth)
    }
}
