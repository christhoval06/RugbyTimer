//
//  DesignTokens.swift
//  RugbyTimer
//
//  Created by @christhoval on 11/08/26.
//

import SwiftUI

extension Color {
    static let pitchVoid = Color(hex: "0B0E14")
    static let pitchEmerald = Color(hex: "10B981")
    static let sinBinAmber = Color(hex: "F59E0B")
    static let cardYellow = Color(hex: "FACC15")
    static let expulsionRed = Color(hex: "EF4444")
    static let iceTitanium = Color(hex: "F9FAFB")
    static let armorBorder = Color(hex: "1F2937")
    static let surfaceContainer = Color(hex: "1D2026")
    
    static let outline = Color(hex: "86948A")
    static let surfaceContainerHighest = Color(hex: "32353C")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

extension Font {
    static func barlowCondensed(size: CGFloat, weight: Font.Weight) -> Font {
        return .custom("BarlowCondensed-Bold", size: size) // Fallback handled by system if custom font not loaded
    }
}
