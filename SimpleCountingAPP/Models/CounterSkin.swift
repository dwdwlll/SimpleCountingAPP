//
//  CounterSkin.swift
//  SimpleCountingAPP
//
//  Created on 2026-01-04.
//

import SwiftUI

struct CounterSkin: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var description: String
    var price: Double // in USD, 0 for free skins
    var isPurchased: Bool
    var isDefault: Bool
    var category: SkinCategory
    
    // Theme colors
    var backgroundColor: String
    var primaryColor: String
    var secondaryColor: String
    var incrementColor: String
    var decrementColor: String
    var resetColor: String
    var textColor: String
    
    // Visual style
    var fontStyle: FontStyle
    var buttonStyle: ButtonStyleType
    
    init(
        id: String,
        name: String,
        description: String,
        price: Double = 0,
        isPurchased: Bool = false,
        isDefault: Bool = false,
        category: SkinCategory = .basic,
        backgroundColor: String = "#FFFFFF",
        primaryColor: String = "#000000",
        secondaryColor: String = "#666666",
        incrementColor: String = "#34C759",
        decrementColor: String = "#FF3B30",
        resetColor: String = "#FF9500",
        textColor: String = "#000000",
        fontStyle: FontStyle = .rounded,
        buttonStyle: ButtonStyleType = .filled
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.isPurchased = isPurchased
        self.isDefault = isDefault
        self.category = category
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.incrementColor = incrementColor
        self.decrementColor = decrementColor
        self.resetColor = resetColor
        self.textColor = textColor
        self.fontStyle = fontStyle
        self.buttonStyle = buttonStyle
    }
    
    // Helper to get Color from hex string
    func color(from hex: String) -> Color {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

enum SkinCategory: String, Codable, CaseIterable {
    case basic = "基础"
    case gradient = "渐变"
    case minimal = "极简"
    case dark = "暗黑"
    case colorful = "炫彩"
    case nature = "自然"
    case tech = "科技"
}

enum FontStyle: String, Codable {
    case rounded = "rounded"
    case serif = "serif"
    case monospaced = "monospaced"
    case standard = "standard"
}

enum ButtonStyleType: String, Codable {
    case filled = "filled"
    case outlined = "outlined"
    case minimal = "minimal"
}

// Extension to provide default skins
extension CounterSkin {
    static let defaultSkin = CounterSkin(
        id: "default",
        name: "默认",
        description: "经典的默认主题",
        isPurchased: true,
        isDefault: true,
        category: .basic,
        backgroundColor: "#FFFFFF",
        primaryColor: "#000000",
        secondaryColor: "#666666",
        incrementColor: "#34C759",
        decrementColor: "#FF3B30",
        resetColor: "#FF9500",
        textColor: "#000000"
    )
    
    static let darkSkin = CounterSkin(
        id: "dark",
        name: "暗夜模式",
        description: "适合夜间使用的深色主题",
        price: 0.99,
        category: .dark,
        backgroundColor: "#1C1C1E",
        primaryColor: "#FFFFFF",
        secondaryColor: "#8E8E93",
        incrementColor: "#30D158",
        decrementColor: "#FF453A",
        resetColor: "#FF9F0A",
        textColor: "#FFFFFF"
    )
    
    static let oceanSkin = CounterSkin(
        id: "ocean",
        name: "海洋",
        description: "清新的海洋渐变主题",
        price: 1.99,
        category: .gradient,
        backgroundColor: "#E0F7FA",
        primaryColor: "#006064",
        secondaryColor: "#00838F",
        incrementColor: "#00ACC1",
        decrementColor: "#E91E63",
        resetColor: "#FF6F00",
        textColor: "#004D40"
    )
    
    static let sunsetSkin = CounterSkin(
        id: "sunset",
        name: "日落",
        description: "温暖的日落渐变主题",
        price: 1.99,
        category: .gradient,
        backgroundColor: "#FFF3E0",
        primaryColor: "#E65100",
        secondaryColor: "#F57C00",
        incrementColor: "#FF9800",
        decrementColor: "#D84315",
        resetColor: "#BF360C",
        textColor: "#BF360C"
    )
    
    static let minimalSkin = CounterSkin(
        id: "minimal",
        name: "极简",
        description: "简约风格的单色主题",
        price: 0.99,
        category: .minimal,
        backgroundColor: "#F5F5F5",
        primaryColor: "#212121",
        secondaryColor: "#757575",
        incrementColor: "#424242",
        decrementColor: "#616161",
        resetColor: "#9E9E9E",
        textColor: "#212121",
        buttonStyle: .outlined
    )
    
    static let neonSkin = CounterSkin(
        id: "neon",
        name: "霓虹",
        description: "炫彩的霓虹灯主题",
        price: 2.99,
        category: .colorful,
        backgroundColor: "#0A0A0A",
        primaryColor: "#00FFFF",
        secondaryColor: "#FF00FF",
        incrementColor: "#00FF00",
        decrementColor: "#FF0080",
        resetColor: "#FFD700",
        textColor: "#00FFFF"
    )
    
    static let forestSkin = CounterSkin(
        id: "forest",
        name: "森林",
        description: "自然清新的森林主题",
        price: 1.99,
        category: .nature,
        backgroundColor: "#E8F5E9",
        primaryColor: "#1B5E20",
        secondaryColor: "#388E3C",
        incrementColor: "#4CAF50",
        decrementColor: "#8D6E63",
        resetColor: "#795548",
        textColor: "#2E7D32"
    )
    
    static let techSkin = CounterSkin(
        id: "tech",
        name: "科技蓝",
        description: "现代科技感主题",
        price: 2.99,
        category: .tech,
        backgroundColor: "#E3F2FD",
        primaryColor: "#0D47A1",
        secondaryColor: "#1976D2",
        incrementColor: "#2196F3",
        decrementColor: "#F44336",
        resetColor: "#FF9800",
        textColor: "#01579B",
        fontStyle: .monospaced
    )
    
    static let allSkins: [CounterSkin] = [
        defaultSkin,
        darkSkin,
        oceanSkin,
        sunsetSkin,
        minimalSkin,
        neonSkin,
        forestSkin,
        techSkin
    ]
}
