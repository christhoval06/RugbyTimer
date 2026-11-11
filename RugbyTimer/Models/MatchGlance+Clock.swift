import Foundation

/// The glance read at a moment: what the clock says and which colour band it is in.
nonisolated extension MatchGlance {
    /// Seconds on the clock at `date`; negative in overtime.
    func clockSeconds(at date: Date) -> Int {
        guard let end = clockEndsAt else { return clockSeconds }
        return Int(end.timeIntervalSince(date).rounded(.up))
    }

    func zone(at date: Date) -> ClockZone {
        let seconds = clockSeconds(at: date)
        return ClockZone.zone(timeRemaining: max(0, seconds), totalDuration: periodSeconds,
                              overtimeSeconds: max(0, -seconds))
    }

    func progress(at date: Date) -> Double {
        let seconds = clockSeconds(at: date)
        return ClockZone.progress(timeRemaining: max(0, seconds), totalDuration: periodSeconds,
                                  overtimeSeconds: max(0, -seconds))
    }

    /// The sin-bin still counting down at `date`, if any.
    func runningSinBinEndsAt(at date: Date) -> Date? {
        guard let end = nextSinBinEndsAt, end > date else { return nil }
        return end
    }

    /// When the period's progress ring started, for a ring that empties on its own.
    var clockStartedAt: Date? {
        guard let end = clockEndsAt, periodSeconds > 0 else { return nil }
        return end.addingTimeInterval(-TimeInterval(periodSeconds))
    }

    /// When the clock turns yellow, for scheduling a redraw.
    var closingAt: Date? {
        clockEndsAt?.addingTimeInterval(-TimeInterval(ClockZone.closingThreshold(totalDuration: periodSeconds)))
    }

    /// "H1", "H1 · PAUSED", "H2 · TIME UP".
    func statusLabel(at date: Date) -> String {
        guard isPlaying else { return periodLabel }
        if zone(at: date) == .timeUp { return "\(periodLabel) · \(timeUpLabel)" } // l10n-ignore: joins translated labels
        if !isRunning { return "\(periodLabel) · \(pausedLabel)" } // l10n-ignore: joins translated labels
        return periodLabel
    }
}
