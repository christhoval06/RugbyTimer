import SwiftUI

/// Reveals `text` one character at a time while the page is active. Tap to show it all.
/// The hidden remainder stays in the layout (clear), so lines never reflow as it types.
struct OnboardingTypewriterTextWidget: View {
    let text: String
    let isActive: Bool
    var characterDelay: Duration = .milliseconds(24)

    @State private var visibleCount = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var characters: [Character] { Array(text) }

    var body: some View {
        let revealed = String(characters.prefix(visibleCount))
        let hidden = String(characters.dropFirst(visibleCount))
        Text("\(Text(revealed).foregroundStyle(Color.outline))\(Text(hidden).foregroundStyle(.clear))")
            .font(.system(size: 17, weight: .regular))
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { visibleCount = characters.count }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(text)
            .task(id: isActive) { await type() }
    }

    private func type() async {
        guard isActive else {
            visibleCount = 0
            return
        }
        if reduceMotion {
            visibleCount = characters.count
            return
        }
        visibleCount = 0
        try? await Task.sleep(for: .milliseconds(350))
        for index in characters.indices {
            guard !Task.isCancelled else { return }
            if visibleCount >= characters.count { return }
            visibleCount = max(visibleCount, index + 1)
            try? await Task.sleep(for: characterDelay)
        }
    }
}
