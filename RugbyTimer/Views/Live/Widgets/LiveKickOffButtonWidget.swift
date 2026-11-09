import SwiftUI

struct LiveKickOffButtonWidget: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 22, weight: .medium))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 19, weight: .black).width(.condensed))
                    Text(subtitle)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .opacity(0.65)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.right")
                    .font(.system(size: 19, weight: .semibold))
            }
            .foregroundStyle(Color.pitchVoid)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 66)
            .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }
}
