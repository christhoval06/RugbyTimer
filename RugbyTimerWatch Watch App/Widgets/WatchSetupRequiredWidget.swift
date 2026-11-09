import SwiftUI

struct WatchSetupRequiredWidget: View {
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
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .scenePadding(.horizontal)
        }
        .background(Color.pitchVoid.ignoresSafeArea())
    }
}

#Preview("No match configured") {
    WatchSetupRequiredWidget()
}
