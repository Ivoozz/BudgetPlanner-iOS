import SwiftUI

public struct ProgressRing: View {
    public let progress: Double // 0.0 to 1.0
    public var lineWidth: CGFloat = 8
    public var tintColor: Color = .appEmerald
    public var trackColor: Color = Color.white.opacity(0.1)

    public init(progress: Double, lineWidth: CGFloat = 8, tintColor: Color = .appEmerald, trackColor: Color = Color.white.opacity(0.1)) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.tintColor = tintColor
        self.trackColor = trackColor
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [tintColor.opacity(0.7), tintColor]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)
        }
    }
}
