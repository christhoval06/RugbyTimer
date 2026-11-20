import SwiftUI

struct WatchMatchToolsWidget: View {
    private enum Tool: String, Identifiable {
        case substitutions, injuries
        var id: Self { self }
    }

    let substitutions: WatchSubstitutionsPageView?
    let injuries: WatchSanctionsPageView?

    @State private var selectedTool: Tool?

    var body: some View {
        VStack(spacing: 6) {
            if substitutions != nil {
                toolButton("Substitutions", symbol: "arrow.left.arrow.right", tool: .substitutions)
            }
            if injuries != nil {
                toolButton("Injury timers", symbol: "cross.case", tool: .injuries)
            }
        }
        .sheet(item: $selectedTool) { tool in
            NavigationStack {
                Group {
                    switch tool {
                    case .substitutions: substitutions
                    case .injuries: injuries
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { selectedTool = nil }
                    }
                }
            }
        }
    }

    private func toolButton(_ title: LocalizedStringKey, symbol: String, tool: Tool) -> some View {
        Button { selectedTool = tool } label: {
            Label(title, systemImage: symbol)
                .font(.system(size: 11, weight: .heavy).width(.condensed))
                .foregroundStyle(Color.iceTitanium)
                .frame(maxWidth: .infinity, minHeight: 36)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.armorBorder))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WatchMatchToolsWidget(
        substitutions: nil,
        injuries: WatchSanctionsPageView(homeTeamName: "Rangers RFC", awayTeamName: "City Lions",
                                         activeCards: [], showsCards: false) { _, _, _ in }
    )
    .padding()
}
