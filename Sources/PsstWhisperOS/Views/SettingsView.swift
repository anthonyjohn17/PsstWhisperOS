import SwiftUI
import AVFoundation

// MARK: - Sidebar Tab Enum

enum SettingsTab: String, CaseIterable {
    case home, vocabulary, snippets, style, scratchpad, configuration, sound, models, history

    var label: String {
        switch self {
        case .home: return "Home"
        case .vocabulary: return "Vocabulary"
        case .snippets: return "Prompts"
        case .style: return "Styles"
        case .scratchpad: return "Notes"
        case .configuration: return "Configuration"
        case .sound: return "Sound"
        case .models: return "Models"
        case .history: return "History"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .vocabulary: return "character.book.closed.fill"
        case .snippets: return "text.bubble.fill"
        case .style: return "textformat"
        case .scratchpad: return "note.text"
        case .configuration: return "gearshape.fill"
        case .sound: return "speaker.wave.2.fill"
        case .models: return "building.columns.fill"
        case .history: return "clock.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .home: return .orange
        case .vocabulary: return .blue
        case .snippets: return .green
        case .style: return .purple
        case .scratchpad: return .yellow
        case .configuration: return .gray
        case .sound: return .pink
        case .models: return .indigo
        case .history: return .teal
        }
    }
}

// MARK: - Settings View (Sidebar Layout)

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: SettingsTab = .home
    @AppStorage(StorageKeys.appearanceMode) private var appearanceRaw: String = AppearanceMode.system.rawValue

    private var appearanceMode: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceRaw) ?? .system },
            set: {
                appearanceRaw = $0.rawValue
                AppearanceMode.postDidChange()
            }
        )
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: AppTheme.sidebarItemSpacing) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    SidebarItemView(
                        icon: tab.icon,
                        iconColor: tab.accentColor,
                        label: tab.label,
                        isSelected: selectedTab == tab
                    )
                    .onTapGesture { selectedTab = tab }
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Appearance")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, 12)

                    PillPicker(
                        options: [.system, .light, .dark],
                        selection: appearanceMode,
                        title: { $0.shortTitle },
                        systemImage: { $0.systemImageName }
                    )
                    .padding(.horizontal, 8)
                }
                .padding(.bottom, 8)

                Text("PsstWhisperOS")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .padding(.top, AppTheme.sidebarTopPadding)
            .frame(width: AppTheme.sidebarWidth)
            .background(AppTheme.sidebarBackground())

            Divider()

            // Content — .environmentObject propagates from the parent SettingsView
            Group {
                switch selectedTab {
                case .home:
                    HomeSettingsTab(selectedTab: $selectedTab)
                case .vocabulary:
                    VocabularySettingsView()
                case .snippets:
                    SnippetsSettingsView()
                case .style:
                    StyleSettingsView()
                case .scratchpad:
                    ScratchpadSettingsView()
                case .configuration:
                    ConfigurationSettingsView()
                case .sound:
                    SoundSettingsView()
                case .models:
                    ModelsLibraryView()
                case .history:
                    HistorySettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 820, height: 580)
    }
}

// MARK: - Home Tab

struct HomeSettingsTab: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedTab: SettingsTab
    @State private var microphoneName: String = "MacBook Pro Microphone"
    @State private var recentTranscriptions: [TranscriptionRecord] = []

    private var hasHistory: Bool {
        !recentTranscriptions.isEmpty
    }

    private var groupedTranscriptions: [(String, [TranscriptionRecord])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let grouped = Dictionary(grouping: recentTranscriptions) { record in
            formatter.string(from: record.date).uppercased()
        }
        return grouped.sorted { a, b in
            guard let dateA = recentTranscriptions.first(where: { formatter.string(from: $0.date).uppercased() == a.key }),
                  let dateB = recentTranscriptions.first(where: { formatter.string(from: $0.date).uppercased() == b.key }) else {
                return a.key > b.key
            }
            return dateA.date > dateB.date
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome back")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)

                if hasHistory {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(groupedTranscriptions.enumerated()), id: \.offset) { groupIndex, group in
                                Text(group.0)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .tracking(0.5)
                                    .padding(.horizontal, 4)
                                    .padding(.top, groupIndex == 0 ? 0 : 20)
                                    .padding(.bottom, 8)

                                ForEach(Array(group.1.enumerated()), id: \.element.id) { entryIndex, record in
                                    VStack(spacing: 0) {
                                        if entryIndex > 0 {
                                            Divider()
                                                .padding(.leading, 80)
                                        }
                                        HStack(alignment: .top, spacing: 12) {
                                            Text(timeString(from: record.date))
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(.secondary)
                                                .frame(width: 64, alignment: .trailing)

                                            Text(record.text)
                                                .font(.system(size: 13))
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Get started")
                                .font(.system(size: 15, weight: .semibold))

                            GetStartedCard(
                                icon: "record.circle",
                                title: "Start recording",
                                subtitle: "Turn your voice to text with a single click.",
                                trailing: shortcutBadge
                            )
                            .onTapGesture {
                                appState.isRecording = true
                            }

                            GetStartedCard(
                                icon: "keyboard",
                                title: "Customize your shortcuts",
                                subtitle: "Change the keyboard shortcuts for PsstWhisperOS."
                            )
                            .onTapGesture {
                                selectedTab = .configuration
                            }

                            GetStartedCard(
                                icon: "textformat",
                                title: "Create a style",
                                subtitle: "Build the perfect style for your workflow."
                            )
                            .onTapGesture {
                                selectedTab = .style
                            }

                            GetStartedCard(
                                icon: "text.book.closed",
                                title: "Add vocabulary",
                                subtitle: "Teach PsstWhisperOS custom words, names, or industry terms."
                            )
                            .onTapGesture {
                                selectedTab = .vocabulary
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            loadMicrophoneName()
            loadTranscriptionData()
        }
    }

    @ViewBuilder
    private var shortcutBadge: some View {
        let holdDisplay = appState.hotkeyConfig.holdKey.displayString
        Text(holdDisplay)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.gray.opacity(0.12)))
            .foregroundColor(.secondary)
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func loadMicrophoneName() {
        if let device = AVCaptureDevice.default(for: .audio) {
            microphoneName = device.localizedName
        }
    }

    private func loadTranscriptionData() {
        let records = HistorySettingsView.loadHistory()
        guard !records.isEmpty else {
            recentTranscriptions = []
            return
        }

        let sorted = records.sorted { $0.date > $1.date }
        recentTranscriptions = Array(sorted.prefix(20))
    }
}

// MARK: - Get Started Card

private struct GetStartedCard<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            trailing

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.1), lineWidth: 1))
        .contentShape(Rectangle())
    }
}

extension GetStartedCard where Trailing == EmptyView {
    init(icon: String, title: String, subtitle: String) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = EmptyView()
    }
}
