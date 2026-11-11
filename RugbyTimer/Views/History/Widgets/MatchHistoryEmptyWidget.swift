import SwiftUI

/// Shown before the first match reaches full time.
struct MatchHistoryEmptyWidget: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.pitchEmerald)
            Text("NO MATCHES YET")
                .font(.system(size: 20, weight: .black).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
            Text("Every match you finish, on iPhone or Apple Watch, is kept here with its full record.")
                .font(.system(size: 14))
                .foregroundStyle(Color.outline)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: 420)
    }
}

#Preview {
    MatchHistoryEmptyWidget()
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
