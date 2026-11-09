import SwiftUI

struct SetupTeamFieldWidget: View {
    let title: LocalizedStringKey
    let role: LocalizedStringKey
    let placeholder: LocalizedStringKey
    let color: Color
    @Binding var name: String

    var body: some View {
        HStack(spacing: 13) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle().fill(color).frame(width: 6, height: 6)
                    Text(title)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.7)
                        .foregroundStyle(color)
                    Spacer()
                    Text(role)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.outline)
                }
                HStack(spacing: 8) {
                    TextField(placeholder, text: $name)
                        .font(.system(size: 23, weight: .bold).width(.condensed))
                        .foregroundStyle(Color.iceTitanium)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .accessibilityLabel(placeholder)
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.outline.opacity(0.7))
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(16)
        .frame(minHeight: 94)
    }
}
