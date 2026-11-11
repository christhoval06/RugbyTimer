import SwiftUI

struct WatchMatchTeamWidget: View {
    let name: String
    let role: LocalizedStringKey
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Capsule().fill(tint).frame(width: 3, height: 16)
            Text(name)
                .font(.system(size: 14, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(Text(role)), \(name)"))
    }
}
