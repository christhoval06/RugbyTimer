import SwiftUI

/// Watch main screen with no match: set up on iPhone, or start a Quick Match on the Watch.
struct WatchHomeView: View {
    var onQuickMatch: (WatchQuickSetup) -> Void = { _ in }

    @State private var showsQuickSetup = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "iphone")
                        .font(.system(size: 26, weight: .regular))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .semibold))
                    Image(systemName: "applewatch")
                        .font(.system(size: 24, weight: .regular))
                }
                .foregroundStyle(Color.pitchEmerald)
                .frame(height: 36)
                .accessibilityHidden(true)

                Text("Set up on iPhone")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.iceTitanium)

                Text("Open RugbyTimer on iPhone and send your match setup to get started.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.outline)
                    .fixedSize(horizontal: false, vertical: true)

                Text("or")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.outline)

                quickMatchButton
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .scenePadding(.horizontal)
        }
        .background(Color.pitchVoid.ignoresSafeArea())
        .sheet(isPresented: $showsQuickSetup) {
            WatchQuickSetupView(onReady: onQuickMatch)
        }
    }

    private var quickMatchButton: some View {
        Button { showsQuickSetup = true } label: {
            Label("QUICK MATCH", systemImage: "bolt.fill")
                .font(.system(size: 13, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.pitchVoid)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Sets up a match on the Watch, without the iPhone")
    }
}

#Preview("No match configured") {
    WatchHomeView()
}
