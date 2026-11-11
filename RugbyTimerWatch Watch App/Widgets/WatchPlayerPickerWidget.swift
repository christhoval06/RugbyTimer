import SwiftUI

/// Digital Crown shirt-number picker. With `allowsNone`, the first row ("—") means no player.
struct WatchPlayerPickerWidget: View {
    @Binding var playerNumber: Int?
    var allowsNone = false
    /// The first row's text with `allowsNone`: no scorer, or no player picked yet.
    var noneLabel: LocalizedStringKey = "— NO PLAYER"
    @Environment(\.playerNumberRange) private var playerNumberRange

    var body: some View {
        Picker("Player", selection: $playerNumber) {
            if allowsNone {
                Text(noneLabel)
                    .font(.system(size: 12, weight: .bold).width(.condensed))
                    .foregroundStyle(Color.outline)
                    .tag(Int?.none)
            }
            ForEach(playerNumberRange, id: \.self) { number in
                Text("#\(number)")
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .tag(Int?.some(number))
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 48)
        .accessibilityLabel(allowsNone ? "Scorer number, optional" : "Player number")
    }
}
