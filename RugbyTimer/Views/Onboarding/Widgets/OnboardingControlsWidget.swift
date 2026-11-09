import SwiftUI

struct OnboardingControlsWidget: View {
    let pageCount: Int
    @Binding var selection: Int
    let tint: Color
    let onFinish: () -> Void

    private var isLastPage: Bool { selection >= pageCount - 1 }

    var body: some View {
        HStack(spacing: 16) {
            OnboardingPageIndicatorWidget(pageCount: pageCount, selection: selection, tint: tint)
            Spacer(minLength: 0)
            Button {
                HapticService.playStartStop()
                if isLastPage {
                    onFinish()
                } else {
                    withAnimation(.easeInOut) { selection += 1 }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(isLastPage ? "GET STARTED" : "NEXT")
                        .font(.system(size: 17, weight: .black).width(.condensed))
                        .tracking(0.5)
                    Image(systemName: isLastPage ? "checkmark" : "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(Color.pitchVoid)
                .padding(.horizontal, 22)
                .frame(minHeight: 54)
                .background(tint, in: RoundedRectangle(cornerRadius: 13))
                .contentTransition(.interpolate)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(isLastPage ? "onboardingFinish" : "onboardingNext")
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .animation(.easeInOut(duration: 0.25), value: isLastPage)
        .animation(.easeInOut(duration: 0.25), value: selection)
    }
}
