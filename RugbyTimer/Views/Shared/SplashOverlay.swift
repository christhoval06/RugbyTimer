import SwiftUI

/// Covers the app with `SplashView` at launch, then fades it out.
/// The owner keeps `isPresented` so it can hold back other covers (onboarding) until the splash is gone.
struct SplashOverlay: ViewModifier {
    static let displaySeconds = 1.4

    /// UI tests launch with `-skipOnboarding` to go straight to Match Setup, so they skip the splash too.
    /// (They also pass `-uiTesting` to start from a clean state; see `LaunchOptions`.)
    static var isSkipped: Bool {
        ProcessInfo.processInfo.arguments.contains("-skipOnboarding") // l10n-ignore
    }

    @Binding var isPresented: Bool
    var compact = false

    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                SplashView(compact: compact)
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(for: .seconds(Self.displaySeconds))
                        withAnimation(.easeOut(duration: 0.35)) { isPresented = false }
                    }
            }
        }
    }
}

extension View {
    func splashOverlay(isPresented: Binding<Bool>, compact: Bool = false) -> some View {
        modifier(SplashOverlay(isPresented: isPresented, compact: compact))
    }
}

#Preview("Splash over the app") {
    @Previewable @State var isPresented = true
    Text(verbatim: "Match Setup") // l10n-ignore
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pitchVoid)
        .splashOverlay(isPresented: $isPresented)
        .preferredColorScheme(.dark)
}
