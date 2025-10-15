//
//  ColorExtensions.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

extension Color {
    // App Color Scheme
    static let primaryRed = Color(hex: "#ae2d27")
    static let secondaryBeige = Color(hex: "#dfb492")
    static let accentYellow = Color(hex: "#ffc934")
    static let successGreen = Color(hex: "#1ed55f")
    static let highlightYellow = Color(hex: "#ffff03")
    static let dangerRed = Color(hex: "#eb262f")
    
    // Additional colors for better UI
    static let backgroundLight = Color(hex: "#fafafa")
    static let textPrimary = Color(hex: "#2c2c2c")
    static let textSecondary = Color(hex: "#666666")
    static let cardBackground = Color.white
    static let divider = Color(hex: "#e0e0e0")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [Color.primaryRed, Color.secondaryBeige],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [Color.accentYellow, Color.highlightYellow],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color.successGreen, Color.accentYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

