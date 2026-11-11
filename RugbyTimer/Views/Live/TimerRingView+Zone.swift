import Foundation

/// The clock's colour band and ring fill; the rule itself lives in `ClockZone`.
extension TimerRingView {
    public typealias Zone = ClockZone

    public static func closingThreshold(totalDuration: Int) -> Int {
        ClockZone.closingThreshold(totalDuration: totalDuration)
    }

    public static func zone(timeRemaining: Int, totalDuration: Int, overtimeSeconds: Int) -> Zone {
        ClockZone.zone(timeRemaining: timeRemaining, totalDuration: totalDuration, overtimeSeconds: overtimeSeconds)
    }

    public static func progress(timeRemaining: Int, totalDuration: Int, overtimeSeconds: Int) -> Double {
        ClockZone.progress(timeRemaining: timeRemaining, totalDuration: totalDuration, overtimeSeconds: overtimeSeconds)
    }
}
