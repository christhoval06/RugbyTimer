//
//  HapticService.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import Foundation
#if os(watchOS)
import WatchKit
#elseif os(iOS)
import UIKit
#endif

public struct HapticService {
    public static let enabledDefaultsKey = "settings.hapticsEnabled"

    /// iPhone feedback follows the Settings toggle; the Watch always plays its referee alerts.
    private static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: enabledDefaultsKey) as? Bool ?? true
    }
    
    public static func playStartStop() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #elseif os(iOS)
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    public static func playCardIssued() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.notification)
        #elseif os(iOS)
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
    
    public static func playSinBinExpired() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #elseif os(iOS)
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    public static func playHalfTime() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.stop)
        #elseif os(iOS)
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }

    /// The hooter: a strong triple pulse when the half's time is up.
    public static func playTimeUp() {
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        for (index, delay) in [0.0, 0.6, 1.2].enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                device.play(index == 2 ? .stop : .notification)
            }
        }
        #elseif os(iOS)
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}
