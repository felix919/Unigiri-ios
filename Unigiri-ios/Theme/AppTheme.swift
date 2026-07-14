import SwiftUI
import UIKit

// 公式サイト (zutomayocard.net) 準拠のブランドカラー (Android版 ui/theme/Color.kt と同一値)
extension Color {
    static let mainPurple = Color(red: 0x42 / 255, green: 0x28 / 255, blue: 0x81 / 255) // #422881 背景
    static let lightPurple = Color(red: 0x8B / 255, green: 0x7F / 255, blue: 0xD6 / 255) // #8B7FD6
    static let brandGreen = Color(red: 0x36 / 255, green: 0xAE / 255, blue: 0x37 / 255) // #36AE37 公式アクセント
    static let surfacePurple = Color(red: 0x2E / 255, green: 0x1B / 255, blue: 0x5B / 255) // #2E1B5B バー類
    static let surfacePurpleContainer = Color(red: 0x37 / 255, green: 0x21 / 255, blue: 0x6C / 255) // #37216C シート類
    static let surfacePurpleHigh = Color(red: 0x3F / 255, green: 0x27 / 255, blue: 0x7C / 255) // #3F277C リスト行など
}

enum AppAppearance {
    // NavigationBar / TabBar を背景パープルと調和する紫トーンに統一する
    static func configure() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color.surfacePurple)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = UIColor(Color.brandGreen)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.brandGreen)]
        itemAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.7)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.surfacePurple)
        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}
