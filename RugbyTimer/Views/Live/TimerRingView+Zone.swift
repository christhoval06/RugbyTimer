import Foundation

/// The clock's colour band and ring fill, shared by the iPhone ring and the Watch dial.
extension TimerRingView {
    /// Colour band of the clock: green for most of the half, yellow when the half is
    /// closing, red once time is up and play runs on to the next dead ball.
    nonisolated public enum Zone: Equatable {
        case normal, closing, timeUp
    }

    /// The closing (yellow) band is the last quarter of the half, capped at 5 minutes,
    /// so a 40-minute half turns yellow at 5:00 and a 7-minute sevens half at 1:45.
    public static func closingThreshold(totalDuration: Int) -> Int {
        min(300, totalDuration / 4)
    }

    public static func zone(timeRemaining: Int, totalDuration: Int, overtimeSeconds: Int) -> Zone {
        if overtimeSeconds > 0 || (timeRemaining <= 0 && totalDuration > 0) { return .timeUp }
        if timeRemaining <= closingThreshold(totalDuration: totalDuration) { return .closing }
        return .normal
    }

    /// Fraction of the ring to draw: full at kickoff, empty at zero, full again (red) in overtime.
    public static func progress(timeRemaining: Int, totalDuration: Int, overtimeSeconds: Int) -> Double {
        if overtimeSeconds > 0 { return 1.0 }
        guard totalDuration > 0 else { return 0.0 }
        return max(0.0, min(Double(timeRemaining) / Double(totalDuration), 1.0))
    }
}
