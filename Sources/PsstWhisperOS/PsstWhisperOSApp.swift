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

    func open(appState: AppState) {
        if let existing = window, existing.isVisible {
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

        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Drop from floating to normal after it's visible so it behaves like a regular window
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            win.level = .normal
        }
    }
}
