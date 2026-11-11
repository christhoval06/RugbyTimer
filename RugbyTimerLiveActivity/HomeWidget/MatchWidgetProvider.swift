import WidgetKit

/// Reads the snapshot the iPhone app saved and plans an entry for each moment the widget must
/// change on its own: the clock turning yellow and red, the break or a sin-bin ending, and a
/// quiet live match giving way to the last result. The app reloads the timeline on every change.
struct MatchWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MatchWidgetEntry {
        MatchWidgetEntry.samples[0]
    }

    func getSnapshot(in context: Context, completion: @escaping (MatchWidgetEntry) -> Void) {
        let snapshot = MatchWidgetStore.load()
        let isBlank = snapshot.liveMatch == nil && snapshot.lastResult == nil
        completion(context.isPreview && isBlank ? MatchWidgetEntry.samples[0] : MatchWidgetEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MatchWidgetEntry>) -> Void) {
        let snapshot = MatchWidgetStore.load()
        let now = Date()
        let dates = [now] + Self.changeDates(for: snapshot).filter { $0 > now }.sorted()
        completion(Timeline(entries: dates.map { MatchWidgetEntry(date: $0, snapshot: snapshot) }, policy: .never))
    }

    static func changeDates(for snapshot: MatchWidgetSnapshot) -> [Date] {
        guard let glance = snapshot.liveMatch else { return [] }
        let matchDates = [glance.breakEndsAt, glance.nextSinBinEndsAt, glance.clockEndsAt, glance.closingAt]
        return matchDates.compactMap { $0 }.filter { $0 < snapshot.liveMatchExpiresAt } + [snapshot.liveMatchExpiresAt]
    }
}
