import SwiftUI
import Cocoa

// MARK: - Appearance

enum AppearanceMode: String, CaseIterable, Identifiable, Hashable {
    case system
    case light
    case dark

    var id: String { rawValue }

    /// Resolved appearance for `NSWindow.appearance` / `NSPanel.appearance`. `nil` = follow system.
    var resolvedNSAppearance: NSAppearance? {
        switch self {
        case .system:
            return nil
        case .light:
            return NSAppearance(named: .aqua)
        case .dark:
            return NSAppearance(named: .darkAqua)
        }
    }

    var shortTitle: String {
        switch self {
        case .system: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var systemImageName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    static func fromStorage() -> AppearanceMode {
        let raw = UserDefaults.standard.string(forKey: StorageKeys.appearanceMode) ?? AppearanceMode.system.rawValue
        return AppearanceMode(rawValue: raw) ?? .system
    }

    static func postDidChange() {
        NotificationCenter.default.post(name: .psstWhisperOSAppearanceDidChange, object: nil)
    }
}

extension Notification.Name {
    static let psstWhisperOSAppearanceDidChange = Notification.Name("psstWhisperOSAppearanceDidChange")
}

// MARK: - App-wide appearance (windows / panels)

enum AppAppearance {
    static func resolvedNSAppearance() -> NSAppearance? {
        AppearanceMode.fromStorage().resolvedNSAppearance
    }

    static func apply(to window: NSWindow?) {
        window?.appearance = resolvedNSAppearance()
    }
}

// MARK: - Design tokens

enum AppTheme {
    static let sidebarWidth: CGFloat = 200
    static let sidebarItemSpacing: CGFloat = 2
    static let sidebarTopPadding: CGFloat = 12
    static let sidebarIconTileSize: CGFloat = 28
    static let sidebarIconCornerRadius: CGFloat = 8
    static let sidebarRowCornerRadius: CGFloat = 10
    static let sidebarSelectionOpacity: Double = 0.10

    static let cardCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let cardBorderOpacity: Double = 0.10

    static let spacingUnit: CGFloat = 8

    static func cardFillColor(colorScheme: ColorScheme) -> Color {
        Color(nsColor: .controlBackgroundColor)
    }

    static func cardBorderColor() -> Color {
        Color.gray.opacity(cardBorderOpacity)
    }

    static func sidebarBackground() -> Color {
        Color(nsColor: .controlBackgroundColor).opacity(0.55)
    }
}
