import SwiftUI

public struct CategoryIconView: View {
    public let icon: String?
    public let colorHex: String?
    public var size: CGFloat = 40
    public var iconSize: CGFloat = 18

    public init(icon: String?, colorHex: String?, size: CGFloat = 40, iconSize: CGFloat = 18) {
        self.icon = icon
        self.colorHex = colorHex
        self.size = size
        self.iconSize = iconSize
    }

    private var themeColor: Color {
        if let hex = colorHex, !hex.isEmpty {
            return Color(hex: hex)
        }
        return Color.appSapphire
    }

    private var sfSymbol: String {
        SFSymbolPicker.mapIcon(icon)
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(themeColor.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .stroke(themeColor.opacity(0.35), lineWidth: 1)
                )

            Image(systemName: sfSymbol)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(themeColor)
        }
        .frame(width: size, height: size)
    }
}
