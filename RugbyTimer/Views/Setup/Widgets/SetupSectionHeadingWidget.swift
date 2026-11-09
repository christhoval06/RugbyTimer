import SwiftUI

struct SetupSectionHeadingWidget: View {
    let number: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 9) {
            Text(number)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.pitchEmerald)
            Text(title)
                .font(.system(size: 13, weight: .heavy).width(.condensed))
                .tracking(0.6)
                .foregroundStyle(Color.iceTitanium)
            Spacer(minLength: 4)
            Text(detail)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .tracking(0.3)
                .foregroundStyle(Color.outline)
        }
    }
}
