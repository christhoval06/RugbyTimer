import SwiftUI

struct WatchScoreType {
    /// `description` stays English because it is synced to the iPhone; `label` is what the referee reads.
    static let all: [WatchScoreType] = [
        WatchScoreType(id: "TRY", label: "TRY", points: 5, description: "Try scored (+5)"),
        WatchScoreType(id: "CONV", label: "CONV", points: 2, description: "Conversion (+2)"),
        WatchScoreType(id: "PEN", label: "PEN", points: 3, description: "Penalty goal (+3)"),
        WatchScoreType(id: "DROP", label: "DROP", points: 3, description: "Drop goal (+3)"),
        WatchScoreType(id: "PT", label: "PEN TRY", points: 7, description: "Penalty try (+7)")
    ]

    let id: String
    let label: LocalizedStringKey
    let points: Int
    let description: String

    var isTry: Bool { id == "TRY" }
}
