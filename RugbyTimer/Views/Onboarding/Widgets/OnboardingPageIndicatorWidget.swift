import SwiftUI

struct OnboardingPageIndicatorWidget: View {
    let pageCount: Int
    let selection: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == selection ? tint : Color.surfaceContainerHighest)
                    .frame(width: index == selection ? 24 : 8, height: 8)
            }
        }
        .animation(.spring(duration: 0.35), value: selection)
        .accessibilityElement()
        .accessibilityLabel("Page \(selection + 1) of \(pageCount)")
    }
}
