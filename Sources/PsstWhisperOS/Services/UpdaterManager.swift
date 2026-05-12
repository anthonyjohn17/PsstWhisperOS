import Foundation
import Sparkle

/// Manages Sparkle auto-updates for direct (non-App Store) distribution.
/// Checks an appcast XML feed for new versions and handles download + install.
@MainActor
final class UpdaterManager: ObservableObject {
    static let shared = UpdaterManager()

    let updaterController: SPUStandardUpdaterController

    @Published var canCheckForUpdates = false

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        if let publicKey = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String,
           publicKey.contains("PLACEHOLDER") {
            updaterController.updater.automaticallyChecksForUpdates = false
            updaterController.updater.automaticallyDownloadsUpdates = false
        }

        // Observe Sparkle's canCheckForUpdates property
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }

    /// The appcast URL is set in Info.plist via SUFeedURL.
    /// To configure: add your appcast URL to Info.plist before shipping.
}
