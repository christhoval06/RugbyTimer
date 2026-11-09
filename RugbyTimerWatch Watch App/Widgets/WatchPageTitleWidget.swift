import SwiftUI

struct WatchPageTitleWidget: View {
    let eyebrow: LocalizedStringKey
    let title: LocalizedStringKey
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 4) {
                Circle().fill(tint).frame(width: 3, height: 3)
                Text(eyebrow)
                    .font(.system(size: 7, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.system(size: 18, weight: .black).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
