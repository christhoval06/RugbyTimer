import SwiftUI
import WidgetKit

/// One moment of the complication: the saved glance read at `date`.
struct MatchClockEntry: TimelineEntry {
    let date: Date
    let glance: MatchGlance

    var tint: Color { glance.tint(at: date) }
    var clockText: Text { glance.clockText(at: date) }
    var statusLabel: String { glance.statusLabel(at: date) }
    var progress: Double { glance.progress(at: date) }
    var runningSinBinEndsAt: Date? { glance.runningSinBinEndsAt(at: date) }
}
