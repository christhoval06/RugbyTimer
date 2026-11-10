import SwiftUI

struct SettingsFooterWidget: View {
    var body: some View {
        VStack(spacing: 6) {
            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityHidden(true)
            Text("RUGBY TIMER \(AppInfo.version)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(Color.outline)
            Text("No accounts. No tracking. Your matches stay on your devices.")
                .font(.system(size: 11))
                .foregroundStyle(Color.outline.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Settings footer") {
    SettingsFooterWidget()
        .padding()
        .background(Color.pitchVoid)
        .preferredColorScheme(.dark)
}
