import SwiftUI
import Cocoa

// MARK: - Floating Recording Overlay View

struct RecordingOverlayView: View {
    @ObservedObject var levelMonitor: AudioLevelMonitor
    @ObservedObject var hotkeyManager: HotkeyManager
    @Environment(\.colorScheme) private var colorScheme

    private var isProcessing: Bool {
        levelMonitor.mode == .processing
    }

    private var isToggleMode: Bool {
        hotkeyManager.state == .toggled
    }

    var body: some View {
        Group {
            if levelMonitor.mode == .modelLoading {
                modelLoadingView
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(loadingPillBackground)
                    .clipShape(Capsule())
            } else {
                ConceptB_FluidWave(
                    audioLevel: levelMonitor.level,
                    isProcessing: isProcessing,
                    isToggleMode: isToggleMode
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: levelMonitor.mode)
    }

    // MARK: - Model Loading

    private var modelLoadingView: some View {
        HStack(spacing: 6) {
            ProgressView()
                .controlSize(.small)
                .scaleEffect(0.55)
                .frame(width: 12, height: 12)
            Text("Loading model…")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.85) : Color.primary)
        }
    }

    private var loadingPillBackground: some View {
        Capsule()
            .fill(
                colorScheme == .dark
                    ? Color(nsColor: NSColor(white: 0.11, alpha: 1))
                    : Color(nsColor: .controlBackgroundColor)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color(nsColor: NSColor(white: 0.24, alpha: 1))
                            : Color.gray.opacity(0.25),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Floating Panel Controller

@MainActor
final class RecordingOverlayController {
    static let shared = RecordingOverlayController()

    private var panel: NSPanel?
    private var appearanceObserver: NSObjectProtocol?

    private init() {
        appearanceObserver = NotificationCenter.default.addObserver(
            forName: .psstWhisperOSAppearanceDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                guard let panel = self.panel else { return }
                AppAppearance.apply(to: panel)
            }
        }
    }

    deinit {
        if let appearanceObserver {
            NotificationCenter.default.removeObserver(appearanceObserver)
        }
    }

    func show(appState: AppState) {
        guard panel == nil else { return }

        let overlayView = RecordingOverlayView(
            levelMonitor: appState.audioLevelMonitor,
            hotkeyManager: appState.hotkeyManager
        )
        let hosting = NSHostingView(rootView: overlayView)

        let panelWidth: CGFloat = 180
        let panelHeight: CGFloat = 80

        let p = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.level = .floating
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        p.isMovableByWindowBackground = false
        p.hidesOnDeactivate = false
        p.ignoresMouseEvents = true
        p.contentView = hosting

        AppAppearance.apply(to: p)

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - panelWidth / 2
            let y = screenFrame.minY + 30
            p.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel = p
        p.orderFrontRegardless()
    }

    func hide() {
        panel?.orderOut(nil)
        panel = nil
    }
}
