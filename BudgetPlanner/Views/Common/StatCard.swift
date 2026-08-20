import SwiftUI

public struct StatCard: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let icon: String
    public let tintColor: Color

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        tintColor: Color = .appEmerald
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.tintColor = tintColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(tintColor)
                    .padding(6)
                    .background(tintColor.opacity(0.15))
                    .clipShape(Circle())
            }

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            if let sub = subtitle {
                Text(sub)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .liquidGlass(cornerRadius: 16)
    }
}
