import SwiftUI

struct WatchSinBinRowWidget: View {
    let card: MatchCard

    private var cardTint: Color { card.type == .yellow ? .cardYellow : .expulsionRed }

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(cardTint)
                .frame(width: 8, height: 12)
            Text("#\(card.playerNumber)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color.iceTitanium)
            Text(card.teamName)
                .font(.system(size: 10, weight: .semibold).width(.condensed))
                .foregroundStyle(Color.outline)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(statusText)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(card.isExpired && card.type == .yellow ? Color.pitchEmerald : cardTint)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(card.type == .yellow
            ? "Yellow card, number \(card.playerNumber), \(card.teamName), \(statusText)"
            : "Red card, number \(card.playerNumber), \(card.teamName), \(statusText)")
    }

    private var statusText: String {
        if card.type == .red { return String(appLocalized: "OFF") }
        if card.isExpired { return String(appLocalized: "READY") }
        return String(format: "%02d:%02d", card.remainingSeconds / 60, card.remainingSeconds % 60)
    }
}
