//
//  AppState+HalfTimeBreak.swift
//  RugbyTimer
//

import Foundation

extension AppState {
    /// When the half-time interval is due to end; nil outside the break.
    public var halfTimeBreakEndsAt: Date? {
        guard matchPeriod == .halfTime, let halfTimeStartedAt else { return nil }
        return halfTimeStartedAt.addingTimeInterval(TimeInterval(halfTimeBreakSeconds))
    }
}
