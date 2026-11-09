import SwiftUI

struct LiveScoreTypeTileWidget: View {
    let points: Int
    let label: LocalizedStringResource

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("+\(points)")
                .font(.system(size: 28, weight: .black).width(.condensed))
                .foregroundStyle(Color.pitchVoid)
            Text(label)
                .font(.system(size: 11, weight: .heavy))
                .tracking(0.6)
                .foregroundStyle(Color.pitchVoid.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 58)
        .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
