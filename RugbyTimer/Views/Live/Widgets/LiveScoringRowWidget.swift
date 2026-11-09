import SwiftUI

struct LiveScoringRowWidget: View {
    let event: MatchEvent
    let points: Int
    let runningScore: String
    let tint: Color

    private var scorer: String {
        event.playerNumber.map { "#\($0) · \(event.teamName)" } ?? event.teamName
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(event.minute)'")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(tint)
                .frame(width: 40, height: 34)
                .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 4) {
                Text(event.localizedDescription)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.iceTitanium)
                Text(scorer)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.outline)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 3) {
                Text("+\(points)")
                    .font(.system(size: 17, weight: .black).width(.condensed))
                    .foregroundStyle(tint)
                Text(runningScore)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.outline)
            }
        }
        .padding(14)
        .accessibilityElement(children: .combine)
    }
}
