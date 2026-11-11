import SwiftUI
import WidgetKit

/// Before the first match: the app's name and "NO MATCHES YET".
struct MatchWidgetEmptyView: View {
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "figure.rugby")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color.pitchEmerald)
            Spacer(minLength: 4)
            Text(verbatim: "RUGBY TIMER") // l10n-ignore: app name
                .font(.system(size: 22, weight: .black).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
            Text(verbatim: label)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.outline)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview(as: .systemSmall) {
    MatchWidget()
} timeline: {
    MatchWidgetEntry.samples[3]
}
