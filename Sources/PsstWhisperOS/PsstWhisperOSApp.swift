import SwiftUI
import Cocoa

@MainActor
enum ApplicationRelauncher {
    static func relaunch() {
        let bundlePath = Bundle.main.bundlePath
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-n", bundlePath]
        do {
            try task.run()
        } catch {
            print("ApplicationRelauncher: failed to relaunch at \(bundlePath) — \(error)")
        }
        NSApplication.shared.terminate(nil)
    }
}

@main
struct PsstWhisperOSApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isRecording ? "record.circle.fill" : "mic")
        }
        .menuBarExtraStyle(.menu)
    }
}

/// Manages a standalone NSWindow for settings — reliable unlike SwiftUI's Settings scene
/// which doesn't work properly with .menu style MenuBarExtra in SPM builds.
@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var window: NSWindow?
    private var hostingView: NSHostingView<AnyView>?
    private var appearanceObserver: NSObjectProtocol?

    private init() {
        appearanceObserver = NotificationCenter.default.addObserver(
            forName: .psstWhisperOSAppearanceDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.applyAppearanceToSettingsWindow()
            }
        }
    }

    deinit {
        if let appearanceObserver {
            NotificationCenter.default.removeObserver(appearanceObserver)
        }
    }

    func open(appState: AppState) {
        if let existing = window, existing.isVisible {
            AppAppearance.apply(to: existing)
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
            .environmentObject(appState)

        let hosting = NSHostingView(rootView: AnyView(settingsView))
        hostingView = hosting

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 820, height: 580),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        win.title = "PsstWhisperOS Settings"
        win.contentView = hosting
        win.center()
        win.isReleasedWhenClosed = false
        win.level = .floating  // Ensure it appears above other windows
        window = win

        AppAppearance.apply(to: win)

        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Drop from floating to normal after it's visible so it behaves like a regular window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            win.level = .normal
        }
    }

    private func applyAppearanceToSettingsWindow() {
        if let win = window {
            AppAppearance.apply(to: win)
        }
    }
}
