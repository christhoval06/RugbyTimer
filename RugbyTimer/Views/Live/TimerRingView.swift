//
//  TimerRingView.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import SwiftUI

public struct TimerRingView: View {
    public let timeRemaining: Int
    public let totalDuration: Int
    public let isRunning: Bool
    public var overtimeSeconds: Int = 0

    public init(timeRemaining: Int, totalDuration: Int, isRunning: Bool, overtimeSeconds: Int = 0) {
        self.timeRemaining = timeRemaining
        self.totalDuration = totalDuration
        self.isRunning = isRunning
        self.overtimeSeconds = overtimeSeconds
    }

    /// Colour band of the clock: green for most of the half, yellow when the half is
    /// closing, red once time is up and play runs on to the next dead ball.
    public enum Zone: Equatable {
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

    private var isOvertime: Bool { overtimeSeconds > 0 }

    private var zone: Zone {
        Self.zone(timeRemaining: timeRemaining, totalDuration: totalDuration, overtimeSeconds: overtimeSeconds)
    }

    private var ringColor: Color {
        switch zone {
        case .normal: .pitchEmerald
        case .closing: .cardYellow
        case .timeUp: .expulsionRed
        }
    }

    private var statusText: LocalizedStringKey {
        if zone == .timeUp { return "TIME UP" }
        return isRunning ? "RUNNING" : "PAUSED"
    }

    /// Fraction of the ring to draw: full at kickoff, empty at zero, full again (red) in overtime.
    public static func progress(timeRemaining: Int, totalDuration: Int, overtimeSeconds: Int) -> Double {
        if overtimeSeconds > 0 { return 1.0 }
        guard totalDuration > 0 else { return 0.0 }
        return max(0.0, min(Double(timeRemaining) / Double(totalDuration), 1.0))
    }

    private var progress: Double {
        Self.progress(timeRemaining: timeRemaining, totalDuration: totalDuration, overtimeSeconds: overtimeSeconds)
    }
    
    public var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.armorBorder, lineWidth: 6)
                .padding(4)
            
            // Progress Ring
            Circle()
                .trim(from: 0.0, to: CGFloat(max(0.0, min(progress, 1.0))))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(4)
                // A paused clock keeps its zone colour but dims, so pause never reads as a warning.
                .opacity(isRunning ? 1 : 0.4)
                .animation(.linear(duration: 1.0), value: progress)
                .animation(.easeInOut(duration: 0.4), value: zone)
            
            // Center Time Display
            VStack(spacing: 2) {
                Text(statusText)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isRunning || zone == .timeUp ? ringColor : .outline)
                    .tracking(0.5)
                
                Text(isOvertime ? "+" + formatTime(overtimeSeconds) : formatTime(timeRemaining))
                    #if os(watchOS)
                    .font(.system(size: 22, weight: .heavy, design: .monospaced))
                    #else
                    .font(.system(size: 30, weight: .heavy, design: .monospaced))
                    #endif
                    .foregroundColor(.iceTitanium)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}


#Preview {
    VStack(spacing: 20) {
        // Paused State (Amber)
        TimerRingView(
            timeRemaining: 2345,
            totalDuration: 2400,
            isRunning: false
        )
        .frame(width: 150, height: 150)
        
        // Running State (Emerald)
//        TimerRingView(
//            timeRemaining: 1850,
//            totalDuration: 2400,
//            isRunning: true
//        )
//        .frame(width: 150, height: 150)
    }
    .padding()
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
