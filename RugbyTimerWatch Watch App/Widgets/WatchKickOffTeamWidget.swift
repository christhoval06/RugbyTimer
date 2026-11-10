import SwiftUI

/// "KO · CITY LIONS": the team kicking off, from the coin toss.
struct WatchKickOffTeamWidget: View {
    let label: LocalizedStringKey
    let teamName: String
    /// Ready screen only: redo the toss before kick-off.
    var onRedo: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.lefthalf.filled")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.sinBinAmber)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.outline)
            Text(teamName.uppercased())
                .font(.system(size: 13, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            if let onRedo {
                Button(action: onRedo) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.sinBinAmber)
                        .frame(width: 26, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Redo coin toss")
            }
        }
        .padding(.horizontal, 8)
        .frame(minHeight: 24)
        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 6))
        .accessibilityElement(children: .contain)
    }
}

#Preview("Kick-off team") {
    WatchKickOffTeamWidget(label: "H2 KO", teamName: "Rangers RFC")
        .padding()
}
