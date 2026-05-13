import SwiftUI

// MARK: - Snippet Model (prompts use the same persistence key `snippets`)

struct Snippet: Codable, Identifiable {
    let id: UUID
    var trigger: String
    var expansion: String

    init(id: UUID = UUID(), trigger: String = "", expansion: String = "") {
        self.id = id
        self.trigger = trigger
        self.expansion = expansion
    }
}

// MARK: - Prompts Settings View

struct SnippetsSettingsView: View {
    @State private var snippets: [Snippet] = []
    @State private var editingSnippetID: UUID?
    @State private var searchText = ""
    @AppStorage(StorageKeys.snippetsBannerDismissed) private var bannerDismissed: Bool = false

    private let storageKey = StorageKeys.snippets

    private var filteredSnippets: [Snippet] {
        if searchText.isEmpty { return snippets }
        let query = searchText.lowercased()
        return snippets.filter {
            $0.trigger.lowercased().contains(query) ||
            $0.expansion.lowercased().contains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Prompts")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: addSnippet) {
                        Text("New Prompt")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary))
                    }
                    .buttonStyle(.plain)
                }

                if !bannerDismissed {
                    heroBanner
                }

                SettingsCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                            TextField("Search prompts...", text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 12))
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 11))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text("\(snippets.count) \(snippets.count == 1 ? "prompt" : "prompts")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if filteredSnippets.isEmpty {
                    SettingsCard {
                        VStack(spacing: 8) {
                            Image(systemName: "text.quote")
                                .font(.system(size: 28))
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Text(snippets.isEmpty ? "No prompts yet" : "No matching prompts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(snippets.isEmpty ? "Create trigger phrases that expand into reusable AI instructions. Click \"New Prompt\" to add one." : "Try a different search term.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Text("Prompt trigger")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Prompt text")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Color.clear.frame(width: 28)
                            }
                            .padding(.horizontal, 4)

                            LazyVStack(spacing: 6) {
                                ForEach(filteredSnippets) { snippet in
                                    if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
                                        SnippetEntryRow(
                                            snippet: $snippets[index],
                                            isEditing: editingSnippetID == snippet.id,
                                            onTap: { editingSnippetID = snippet.id },
                                            onDelete: { deleteSnippet(snippet.id) },
                                            onCommit: {
                                                editingSnippetID = nil
                                                saveSnippets()
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .onAppear { loadSnippets() }
    }

    // MARK: - Default prompts (shipped once)

    static func defaultBuiltInPrompts() -> [Snippet] {
        [
            Snippet(
                trigger: "debug brief",
                expansion: "Create a debugging brief with observed behavior, expected behavior, suspected root causes, files to inspect, and verification steps."
            ),
            Snippet(
                trigger: "refactor plan",
                expansion: "Create a safe refactor plan. Preserve behavior, list files to modify, risks, tests, and rollback notes."
            ),
            Snippet(
                trigger: "cursor task",
                expansion: "Turn this into a precise Cursor agent instruction with objective, constraints, implementation steps, and acceptance criteria."
            ),
            Snippet(
                trigger: "commit summary",
                expansion: "Write a concise git commit message summarizing the changes described above."
            ),
            Snippet(
                trigger: "architecture review",
                expansion: "Review the described architecture. Identify strengths, risks, missing components, and recommendations."
            ),
        ]
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button(action: dismissBanner) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            Text("Reusable AI instructions from a single phrase.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Text("Define a prompt trigger you can say while dictating. PsstWhisperOS expands it into full instructions for Cursor, Claude, or any workflow.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(2)

            VStack(alignment: .leading, spacing: 6) {
                examplePill(trigger: "debug brief", expansion: "Create a debugging brief with …")
                examplePill(trigger: "cursor task", expansion: "Turn this into a precise Cursor agent instruction …")
                examplePill(trigger: "commit summary", expansion: "Write a concise git commit message …")
            }
            .padding(.top, 4)

            Button(action: addSnippet) {
                Text("New prompt")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.2)))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.25, green: 0.15, blue: 0.55),
                            Color(red: 0.35, green: 0.20, blue: 0.65),
                            Color(red: 0.50, green: 0.25, blue: 0.60),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func examplePill(trigger: String, expansion: String) -> some View {
        HStack(spacing: 6) {
            Text(trigger)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.white.opacity(0.2)))

            Image(systemName: "arrow.right")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.6))

            Text(expansion)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
        }
    }

    // MARK: - Actions

    private func addSnippet() {
        let snippet = Snippet()
        snippets.insert(snippet, at: 0)
        editingSnippetID = snippet.id
        saveSnippets()
    }

    private func deleteSnippet(_ id: UUID) {
        snippets.removeAll { $0.id == id }
        if editingSnippetID == id {
            editingSnippetID = nil
        }
        saveSnippets()
    }

    private func dismissBanner() {
        bannerDismissed = true
    }

    private func loadSnippets() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            // First run (or reset): no prompts storage yet — ship built-in defaults.
            snippets = Self.defaultBuiltInPrompts()
            saveSnippets()
            return
        }
        snippets = (try? JSONDecoder().decode([Snippet].self, from: data)) ?? []
    }

    private func saveSnippets() {
        guard let data = try? JSONEncoder().encode(snippets) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

// MARK: - Snippet Entry Row

private struct SnippetEntryRow: View {
    @Binding var snippet: Snippet
    let isEditing: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onCommit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            if isEditing {
                TextField("Prompt trigger", text: $snippet.trigger)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                    .onSubmit { onCommit() }

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Prompt text…", text: $snippet.expansion)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                    .onSubmit { onCommit() }

                Button(action: onCommit) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            } else {
                Text(snippet.trigger.isEmpty ? "(empty)" : snippet.trigger)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(snippet.trigger.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(snippet.expansion.isEmpty ? "(empty)" : snippet.expansion)
                    .font(.system(size: 12))
                    .foregroundColor(snippet.expansion.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .frame(width: 28)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isEditing ? Color.accentColor.opacity(0.06) : Color.gray.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isEditing ? Color.accentColor.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
