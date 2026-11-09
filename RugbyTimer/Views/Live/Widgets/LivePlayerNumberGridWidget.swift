import SwiftUI

struct LivePlayerNumberGridWidget: View {
    @Binding var selectedNumber: Int?
    let tint: Color
    /// When true the first cell is "–" so the referee can record without a player number.
    var allowsNone = false

    @Environment(\.playerNumberRange) private var playerNumberRange

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 6), spacing: 6) {
            if allowsNone {
                cell(label: "–", isSelected: selectedNumber == nil) { selectedNumber = nil }
                    .accessibilityLabel("No player number")
            }
            ForEach(playerNumberRange, id: \.self) { number in
                cell(label: "\(number)", isSelected: selectedNumber == number) { selectedNumber = number }
            }
        }
    }

    private func cell(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            HapticService.playStartStop()
            action()
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(isSelected ? Color.pitchVoid : Color.iceTitanium)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(isSelected ? tint : Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(isSelected ? tint : Color.armorBorder))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
