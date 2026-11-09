//
//  TimerService.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation
import Combine

public protocol TimeKeeping {
    var timeRemaining: Int { get }
    var isRunning: Bool { get }
    func start()
    func pause()
    func reset(to seconds: Int)
}

public class MatchTimerService: ObservableObject, TimeKeeping {
    /// Signed match clock: positive while the half is running down, negative once time is up
    /// and play continues until the ball is dead (overtime).
    @Published public private(set) var clockSeconds: Int
    @Published public private(set) var isRunning: Bool = false

    public var timeRemaining: Int { max(0, clockSeconds) }
    public var overtimeSeconds: Int { max(0, -clockSeconds) }
    public var isInOvertime: Bool { clockSeconds < 0 }

    /// Wall-clock moment the running period reaches zero. The clock is derived from this
    /// date, so it stays correct after the app is suspended or backgrounded.
    public private(set) var endDate: Date?

    private let now: () -> Date
    private var timerCancellable: AnyCancellable?

    public init(initialSeconds: Int = 2400, now: @escaping () -> Date = Date.init) {
        self.clockSeconds = initialSeconds
        self.now = now
    }

    public func start() {
        guard !isRunning else { return }
        endDate = now().addingTimeInterval(TimeInterval(clockSeconds))
        isRunning = true
        startTicking()
    }

    public func pause() {
        if let endDate {
            clockSeconds = reading(until: endDate)
        }
        endDate = nil
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    public func reset(to seconds: Int) {
        pause()
        clockSeconds = seconds
    }

    /// Recomputes the clock from the wall clock; call when the app returns to the foreground.
    /// The clock keeps running past zero into overtime until the period is ended.
    public func refresh() {
        guard isRunning, let endDate else { return }
        let reading = reading(until: endDate)
        if reading != clockSeconds {
            clockSeconds = reading
        }
    }

    /// The phone mirrors the Watch clock. `clock` is signed: negative values are overtime.
    /// With the Watch's `endDate` the phone keeps counting on its own between updates, so the
    /// display stays right while the Watch is out of range; without it the reading is shown as-is.
    public func displayWatchTime(remaining clock: Int, isRunning: Bool, endDate: Date? = nil) {
        guard isRunning, let endDate else {
            timerCancellable?.cancel()
            timerCancellable = nil
            self.endDate = nil
            clockSeconds = clock
            self.isRunning = isRunning
            return
        }
        self.endDate = endDate
        self.isRunning = true
        refresh()
        if timerCancellable == nil { startTicking() }
    }

    private func startTicking() {
        timerCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.refresh() }
    }

    private func reading(until endDate: Date) -> Int {
        Int(endDate.timeIntervalSince(now()).rounded(.up))
    }
}
