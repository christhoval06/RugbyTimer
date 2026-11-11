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
    HStack(spacing: 20) {
        TimerRingView(timeRemaining: 2345, totalDuration: 2400, isRunning: false)
        TimerRingView(timeRemaining: 204, totalDuration: 2400, isRunning: true)
        TimerRingView(timeRemaining: 0, totalDuration: 2400, isRunning: true, overtimeSeconds: 37)
    }
    .frame(height: 150)
    .padding()
    .background(Color.pitchVoid)
    .preferredColorScheme(.dark)
}
