import SwiftUI

struct DeveloperView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                DeveloperProfileWidget()
                DeveloperRugbyCareerWidget()
                DeveloperLinksWidget()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(Color.pitchVoid.ignoresSafeArea())
        .navigationTitle("Developer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Developer") {
    NavigationStack { DeveloperView() }
        .preferredColorScheme(.dark)
}
