import SwiftUI

struct LiveSheetHeaderWidget: View {
    let eyebrow: LocalizedStringKey
    let title: LocalizedStringKey
    let tint: Color
    let onCancel: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(3)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 28, weight: .black).width(.condensed))
                    .foregroundStyle(Color.iceTitanium)
            }
            Spacer()
            Button("Cancel", action: onCancel)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.outline)
        }
    }
}
