import Foundation

enum StorageKeys {
    static let hasRequestedPermissions = "hasRequestedPermissions"
    static let autoPaste = "autoPaste"
    static let formatText = "formatText"
    static let hotkeyConfig = "hotkeyConfig"
    static let customModes = "customModes"
    static let selectedMode = "selectedMode"
    static let playStartSound = "playStartSound"
    static let playStopSound = "playStopSound"
    static let soundVolume = "soundVolume"
    static let whisperModel = "whisperModel"
    static let writingStyle = "writingStyle"
    static let vocabularyEntries = "vocabularyEntries"
    static let snippets = "snippets"
    static let transcriptionHistory = "transcriptionHistory"
    static let scratchpadNotes = "scratchpadNotes"
    static let snippetsBannerDismissed = "snippetsBannerDismissed"
    /// Legacy UserDefaults key; retained for existing installs.
    static let vocabularyBannerDismissed = "dictionaryBannerDismissed"
    static let styleBannerDismissed = "styleBannerDismissed"
    static let showInDock = "showInDock"
    static let appearanceMode = "appearanceMode"
}
