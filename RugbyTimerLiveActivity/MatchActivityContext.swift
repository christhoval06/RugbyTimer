import ActivityKit
import SwiftUI
import WidgetKit

extension ActivityViewContext where Attributes == MatchActivityAttributes {
    var glance: MatchGlance { state }

    /// The moment to read the glance at. Once the content is stale (the clock or the break ran out
    /// without an update from the app), read it as at that end, so it shows time up rather than green.
    var displayDate: Date {
        guard isStale, let end = state.clockEndsAt ?? state.breakEndsAt else { return Date() }
        return max(end, Date())
    }

    var tint: Color { state.tint(at: displayDate) }
    var clockText: Text { state.clockText(at: displayDate) }
    var statusLabel: String { state.statusLabel(at: displayDate) }
}
