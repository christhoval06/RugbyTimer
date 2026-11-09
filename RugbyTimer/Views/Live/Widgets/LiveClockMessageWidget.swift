import SwiftUI

struct LiveClockMessageWidget: View {
    let symbol: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let tint: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(tint)
                .frame(width: 64, height: 64)
                .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
                .accessibilityHidden(true)
            Text(title)
                .font(.system(size: 26, weight: .black).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.outline)
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
    }
}
