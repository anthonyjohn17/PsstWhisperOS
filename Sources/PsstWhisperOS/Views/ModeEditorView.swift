import SwiftUI

struct ModeEditorView: View {
    @State var mode: CustomMode
    var onSave: (CustomMode) -> Void
    @Environment(\.dismiss) private var dismiss

    private let iconOptions = [
        "text.bubble", "doc.text", "envelope", "message",
        "pencil", "highlighter", "bold", "italic",
        "list.bullet", "text.quote", "chevron.left.forwardslash.chevron.right",
        "brain", "sparkles", "wand.and.stars",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(mode.name.isEmpty ? "New Mode" : "Edit Mode")
                    .font(.title2)
                    .fontWeight(.semibold)

                SettingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preset")
                            .font(.headline)
                        TextField("Name", text: $mode.name)
                            .textFieldStyle(.roundedBorder)
                        Picker("Icon", selection: $mode.icon) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Label(icon, systemImage: icon).tag(icon)
                            }
                        }
                    }
                }

                SettingsCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Prompt / template")
                            .font(.headline)
                        TextEditor(text: $mode.prompt)
                            .font(.body)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                            )
                        Text("Use {{text}} as placeholder for the transcribed text")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                SettingsCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.headline)
                        Text(previewText())
                            .font(.callout)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(8)
                    }
                }

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)

                    Spacer()

                    Button("Save") {
                        onSave(mode)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(mode.name.isEmpty)
                }
            }
            .padding(24)
        }
        .frame(width: 420, height: 520)
    }

    private func previewText() -> String {
        let sampleText = "Hello this is a sample transcription"
        if mode.prompt.contains("{{text}}") {
            return mode.prompt.replacingOccurrences(of: "{{text}}", with: sampleText)
        } else if mode.prompt.isEmpty {
            return sampleText
        } else {
            return "\(mode.prompt)\n\n\(sampleText)"
        }
    }
}
