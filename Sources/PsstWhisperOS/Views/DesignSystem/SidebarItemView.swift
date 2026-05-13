import SwiftUI

struct SidebarItemView: View {
    let icon: String
    let iconColor: Color
    let label: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.sidebarIconCornerRadius)
                    .fill(iconColor.opacity(0.22))
                    .frame(width: AppTheme.sidebarIconTileSize, height: AppTheme.sidebarIconTileSize)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .primary : .secondary)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.sidebarRowCornerRadius)
                .fill(isSelected ? Color.accentColor.opacity(AppTheme.sidebarSelectionOpacity) : Color.clear)
        )
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
    }
}
