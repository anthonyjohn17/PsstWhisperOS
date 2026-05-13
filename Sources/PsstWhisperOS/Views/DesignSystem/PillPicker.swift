import SwiftUI

/// Capsule-style segmented control for a small fixed set of options.
struct PillPicker<Selection: Hashable>: View {
    let options: [Selection]
    let title: (Selection) -> String
    let systemImage: ((Selection) -> String)?
    @Binding var selection: Selection

    init(
        options: [Selection],
        selection: Binding<Selection>,
        title: @escaping (Selection) -> String,
        systemImage: ((Selection) -> String)? = nil
    ) {
        self.options = options
        self._selection = selection
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let selected = selection == option
                Button {
                    selection = option
                } label: {
                    HStack(spacing: 4) {
                        if let systemImage {
                            Image(systemName: systemImage(option))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Text(title(option))
                            .font(.system(size: 11, weight: selected ? .semibold : .regular))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
                    .background(
                        Capsule()
                            .fill(selected ? Color.accentColor.opacity(0.22) : Color.clear)
                    )
                    .foregroundStyle(selected ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        )
    }
}
