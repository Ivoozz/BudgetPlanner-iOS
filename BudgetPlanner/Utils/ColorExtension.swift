import SwiftUI

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 100, 116, 139)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    public static let appEmerald = Color(hex: "#10B981")
    public static let appSapphire = Color(hex: "#3B82F6")
    public static let appViolet = Color(hex: "#8B5CF6")
    public static let appRose = Color(hex: "#F43F5E")
    public static let appAmber = Color(hex: "#F59E0B")
    public static let appSlate = Color(hex: "#64748B")
    public static let appDarkBackground = Color(hex: "#090D16")
    public static let appGlassCard = Color(hex: "#131C2E").opacity(0.7)
    public static let appGlassBorder = Color.white.opacity(0.12)
}
