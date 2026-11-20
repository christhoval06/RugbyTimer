import SwiftUI

struct WatchDisplayTogglesWidget: View {
    @AppStorage(WatchDisplayPreferences.extendedLayoutKey)
    private var extendedLayout = WatchDisplayPreferences.standard.extendedLayout
    @AppStorage(WatchDisplayPreferences.showDisciplineKey)
    private var showDiscipline = WatchDisplayPreferences.standard.showDiscipline

    var body: some View {
        Group {
            Toggle("Extended layout", isOn: $extendedLayout)
            Toggle("Show penalties and sanctions", isOn: $showDiscipline)
        }
        .tint(Color.pitchEmerald)
    }
}

#Preview {
    List {
        WatchDisplayTogglesWidget()
    }
}
