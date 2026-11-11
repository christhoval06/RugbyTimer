import SwiftUI

struct WatchDisciplineTeamRowWidget: View {
    let name: String
    let tint: Color
    let yellow: Int
    let red: Int

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(tint).frame(width: 5, height: 5)
            Text(name)
                .font(.system(size: 12, weight: .bold).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 2)
            chip(count: yellow, fill: .cardYellow)
            chip(count: red, fill: .expulsionRed)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name): \(yellow) yellow, \(red) red")
    }

    private func chip(count: Int, fill: Color) -> some View {
        HStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(fill)
                .frame(width: 6, height: 9)
            Text("\(count)")
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundStyle(count > 0 ? Color.iceTitanium : Color.outline)
        }
        .frame(minWidth: 24, alignment: .trailing)
        .opacity(count > 0 ? 1 : 0.55)
    }
}
