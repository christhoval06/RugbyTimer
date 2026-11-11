import Foundation

extension MatchClockEntry {
    /// Preview and gallery entries, from the shared sample glances.
    static var samples: [MatchClockEntry] {
        let now = Date()
        return MatchGlance.samples(now: now).map { MatchClockEntry(date: now, glance: $0) }
    }
}
