import SwiftUI
import UIKit

struct LiveMatchRecordSheetWidget: View {
    let record: String
    let subject: String
    let onDone: () -> Void

    @State private var didCopy = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FULL TIME")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(3)
                        .foregroundStyle(Color.pitchEmerald)
                    Text("MATCH RECORD")
                        .font(.system(size: 28, weight: .black).width(.condensed))
                        .foregroundStyle(Color.iceTitanium)
                }
                Spacer()
                Button("Done", action: onDone)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.pitchEmerald)
                    .accessibilityIdentifier("closeMatchRecord")
            }
            .padding(20)

            ScrollView {
                Text(record)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Color.iceTitanium)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
            .padding(.horizontal, 20)

            VStack(spacing: 10) {
                Button {
                    HapticService.playStartStop()
                    ShareSheetPresenter.share(text: record, subject: subject)
                } label: {
                    Label("SHARE TEXT", systemImage: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .black).width(.condensed))
                        .foregroundStyle(Color.pitchVoid)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.pitchEmerald, in: RoundedRectangle(cornerRadius: 13))
                }
                .accessibilityIdentifier("shareMatchRecordText")

                Button {
                    UIPasteboard.general.string = record
                    HapticService.playStartStop()
                    didCopy = true
                } label: {
                    Label(didCopy ? "COPIED" : "COPY TEXT", systemImage: didCopy ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, weight: .heavy).width(.condensed))
                        .tracking(0.6)
                        .foregroundStyle(Color.pitchEmerald)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 11))
                        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.armorBorder))
                }
                .accessibilityIdentifier("copyMatchRecordText")
            }
            .buttonStyle(.plain)
            .padding(20)
        }
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pitchVoid.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }
}
