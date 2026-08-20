import SwiftUI

// MARK: - Apple Liquid Glass Design System
// Conforming to Apple's Liquid Glass UI guidelines (translucency, specular highlights, refraction, depth, and vibrant materials)

public struct LiquidGlassModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var borderOpacity: Double
    public var strokeColor: Color
    public var glowColor: Color
    public var glowRadius: CGFloat

    public init(
        cornerRadius: CGFloat = 22,
        borderOpacity: Double = 0.35,
        strokeColor: Color = Color.white.opacity(0.15),
        glowColor: Color = Color.appEmerald.opacity(0.15),
        glowRadius: CGFloat = 14
    ) {
        self.cornerRadius = cornerRadius
        self.borderOpacity = borderOpacity
        self.strokeColor = strokeColor
        self.glowColor = glowColor
        self.glowRadius = glowRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.09),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                // Specular light edge & refractive refraction border
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(borderOpacity),
                                strokeColor,
                                Color.clear,
                                Color.white.opacity(borderOpacity * 0.15),
                                strokeColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: glowColor, radius: glowRadius, x: 0, y: 6)
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

public struct LiquidGlassPillModifier: ViewModifier {
    public var isSelected: Bool
    public var tintColor: Color

    public func body(content: Content) -> some View {
        content
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? tintColor : Color.white.opacity(0.08))
                    .background(Capsule().fill(.ultraThinMaterial.opacity(0.6)))
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isSelected ? 0.6 : 0.25),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: isSelected ? tintColor.opacity(0.35) : Color.clear, radius: 8, x: 0, y: 4)
    }
}

public struct LiquidGlassButtonModifier: ViewModifier {
    public var tintColor: Color
    public var cornerRadius: CGFloat

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                tintColor.opacity(0.95),
                                tintColor.opacity(0.80)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(.ultraThinMaterial))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: tintColor.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Animated Liquid Ambient Background
public struct LiquidBackground: View {
    @State private var animate = false

    public init() {}

    public var body: some View {
        ZStack {
            Color(hex: "#080C15")
                .ignoresSafeArea()

            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height

                ZStack {
                    // Emerald Refractive Orb (Top-Leading)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.appEmerald.opacity(0.28), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.5
                            )
                        )
                        .frame(width: w * 0.95, height: w * 0.95)
                        .offset(x: animate ? -w * 0.25 : w * 0.1, y: animate ? -h * 0.12 : h * 0.02)
                        .blur(radius: 70)

                    // Sapphire Refractive Orb (Center-Trailing)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.appSapphire.opacity(0.25), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.45
                            )
                        )
                        .frame(width: w * 0.85, height: w * 0.85)
                        .offset(x: animate ? w * 0.22 : -w * 0.15, y: animate ? h * 0.25 : h * 0.10)
                        .blur(radius: 65)

                    // Violet / Cyan Refractive Orb (Bottom-Center)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.appViolet.opacity(0.20), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: w * 0.55
                            )
                        )
                        .frame(width: w * 1.0, height: w * 1.0)
                        .offset(x: animate ? -w * 0.1 : w * 0.25, y: animate ? h * 0.55 : h * 0.40)
                        .blur(radius: 80)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 9.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - View Extensions
public extension View {
    func liquidGlass(
        cornerRadius: CGFloat = 22,
        borderOpacity: Double = 0.35,
        strokeColor: Color = Color.white.opacity(0.15),
        glowColor: Color = Color.appEmerald.opacity(0.12),
        glowRadius: CGFloat = 14
    ) -> some View {
        self.modifier(LiquidGlassModifier(
            cornerRadius: cornerRadius,
            borderOpacity: borderOpacity,
            strokeColor: strokeColor,
            glowColor: glowColor,
            glowRadius: glowRadius
        ))
    }

    func liquidPill(isSelected: Bool = false, tintColor: Color = .appEmerald) -> some View {
        self.modifier(LiquidGlassPillModifier(isSelected: isSelected, tintColor: tintColor))
    }

    func liquidButton(tintColor: Color = .appEmerald, cornerRadius: CGFloat = 16) -> some View {
        self.modifier(LiquidGlassButtonModifier(tintColor: tintColor, cornerRadius: cornerRadius))
    }
}
