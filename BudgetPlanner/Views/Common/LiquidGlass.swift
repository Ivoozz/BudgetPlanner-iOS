import SwiftUI

public struct LiquidGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var strokeColor: Color = Color.white.opacity(0.15)
    var backgroundColor: Color = Color(hex: "#121A2A").opacity(0.7)

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial.opacity(0.4))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                strokeColor,
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

public struct LiquidGlassPillModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                Capsule(style: .continuous)
                    .fill(Color(hex: "#1E293B").opacity(0.65))
                    .background(Capsule().fill(.ultraThinMaterial.opacity(0.5)))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}

public extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, strokeColor: Color = Color.white.opacity(0.15)) -> some View {
        self.modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, strokeColor: strokeColor))
    }

    func liquidPill() -> some View {
        self.modifier(LiquidGlassPillModifier())
    }
}
