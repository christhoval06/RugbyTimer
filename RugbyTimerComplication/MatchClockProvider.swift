import WidgetKit

/// Reads the snapshot the Watch app saved and plans an entry for each moment the face must
/// change on its own: the clock turning yellow and red, the break ending, a sin-bin ending.
/// The Watch app reloads the timeline whenever the match changes, so nothing else is scheduled.
struct MatchClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> MatchClockEntry {
        MatchClockEntry.samples[0]
    }

    func getSnapshot(in context: Context, completion: @escaping (MatchClockEntry) -> Void) {
        let snapshot = ComplicationStore.load()
        completion(context.isPreview && snapshot.isIdle ? MatchClockEntry.samples[0] : MatchClockEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MatchClockEntry>) -> Void) {
        let snapshot = ComplicationStore.load()
        let now = Date()
        let dates = [now] + Self.changeDates(for: snapshot).filter { $0 > now }.sorted()
        completion(Timeline(entries: dates.map { MatchClockEntry(date: $0, snapshot: snapshot) }, policy: .never))
    }

    static func changeDates(for snapshot: ComplicationSnapshot) -> [Date] {
        var dates = [snapshot.breakEndsAt, snapshot.nextSinBinEndsAt].compactMap { $0 }
        if let end = snapshot.clockEndsAt {
            dates.append(end)
            let closing = ClockZone.closingThreshold(totalDuration: snapshot.periodSeconds)
            dates.append(end.addingTimeInterval(-TimeInterval(closing)))
        }
        return dates
    }
}
