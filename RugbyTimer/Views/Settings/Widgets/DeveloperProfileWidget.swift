import SwiftUI

struct DeveloperProfileWidget: View {
    private var initials: String {
        AppInfo.developerName.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Text(initials)
                    .font(.system(size: 28, weight: .black).width(.condensed))
                    .foregroundStyle(Color.pitchVoid)
                    .frame(width: 76, height: 76)
                    .background(Color.pitchEmerald, in: Circle())
                    .overlay(Circle().stroke(Color.pitchEmerald.opacity(0.3), lineWidth: 6).padding(-6))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppInfo.developerHandle.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(Color.pitchEmerald)
                    Text(AppInfo.developerName.uppercased())
                        .font(.system(size: 28, weight: .black).width(.condensed))
                        .foregroundStyle(Color.iceTitanium)
                    Text(AppInfo.developerRole)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.outline)
                }
            }
            Text(AppInfo.developerBio)
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundStyle(Color.iceTitanium.opacity(0.85))
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.surfaceContainer, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.armorBorder))
        }
    }
}
