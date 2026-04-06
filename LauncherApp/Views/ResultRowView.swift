import SwiftUI

struct ResultRowView: View {
    /// Row height (vertical padding 8×2 + icon 32) + inter-row spacing 2
    static let estimatedHeight: CGFloat = 50

    let result: SearchResult
    let isSelected: Bool
    var onHide: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: result.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(1)

                Text(result.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isSelected {
                if case .calculation = result {
                    Text("⏎ Copy")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                } else {
                    Text("⏎ Open")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
        .contextMenu {
            if case .app = result, let onHide {
                Button("Hide from Launcher") {
                    onHide()
                }
            }
        }
    }
}
