import SwiftUI

/// "H1 7–0 · H2 5–7 · ET 3–0". The second half is omitted at half-time, extra time unless played.
struct WatchScoreByHalfWidget: View {
    let firstHalf: (home: Int, away: Int)
    var secondHalf: (home: Int, away: Int)? = nil
    var extraTime: (home: Int, away: Int)? = nil

    var body: some View {
        HStack(spacing: 8) {
            half("H1", firstHalf)
            if let secondHalf {
                half("H2", secondHalf)
            }
            if let extraTime {
                half("ET", extraTime)
            }
            Spacer(minLength: 0)
        }
    }

    private func half(_ label: LocalizedStringKey, _ score: (home: Int, away: Int)) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.outline)
            Text(verbatim: "\(score.home)–\(score.away)")
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Text(label)): \(score.home) to \(score.away)"))
    }
}

#Preview("Score by half") {
    WatchScoreByHalfWidget(firstHalf: (7, 0), secondHalf: (5, 7))
        .padding()
}
