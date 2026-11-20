import SwiftUI

/// Pins the footer until an upward swipe and restores it on a downward swipe.
struct ScrollWithCollapsibleFooter<Content: View, Footer: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsFooter = true

    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(content: content)
                .clipped()
                .simultaneousGesture(
                    DragGesture(minimumDistance: 24, coordinateSpace: .global)
                        .onEnded { swipe in
                            let movement = swipe.translation
                            guard abs(movement.height) >= 24, abs(movement.height) > abs(movement.width) else { return }

                            let shouldShowFooter = movement.height > 0
                            guard shouldShowFooter != showsFooter else { return }
                            withAnimation(reduceMotion ? nil : .smooth(duration: 0.34)) {
                                showsFooter = shouldShowFooter
                            }
                        }
                )
            if showsFooter {
                footer()
                    .transition(.offset(y: 24).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    ScrollWithCollapsibleFooter {
        LiveScoreboardWidget(homeTeamName: "Rangers RFC", awayTeamName: "City Lions", homeScore: 12, awayScore: 7)
    } footer: {
        LiveSetupButtonWidget(isProminent: false, onReturnToSetup: {})
    }
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
