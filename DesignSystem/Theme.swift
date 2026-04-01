import SwiftUI

struct ThemePalette: Hashable {
    let backgroundTop: Color
    let backgroundBottom: Color
    let cardFill: Color
    let cardTint: Color
    let accent: Color
    let accentSecondary: Color
    let textPrimary: Color
    let textSecondary: Color
    let divider: Color
    let shadow: Color
}

enum EarnzaTheme {
    static func palette(for style: ThemeStyle) -> ThemePalette {
        switch style {
        case .light:
            ThemePalette(
                backgroundTop: Color(red: 0.96, green: 0.97, blue: 0.95),
                backgroundBottom: Color(red: 0.90, green: 0.94, blue: 0.93),
                cardFill: .white.opacity(0.74),
                cardTint: Color(red: 0.14, green: 0.38, blue: 0.33),
                accent: Color(red: 0.06, green: 0.51, blue: 0.34),
                accentSecondary: Color(red: 0.18, green: 0.36, blue: 0.82),
                textPrimary: Color(red: 0.10, green: 0.13, blue: 0.16),
                textSecondary: Color(red: 0.32, green: 0.38, blue: 0.42),
                divider: Color.black.opacity(0.08),
                shadow: Color.black.opacity(0.10)
            )
        case .dark:
            ThemePalette(
                backgroundTop: Color(red: 0.07, green: 0.08, blue: 0.10),
                backgroundBottom: Color(red: 0.12, green: 0.12, blue: 0.16),
                cardFill: Color.white.opacity(0.07),
                cardTint: Color(red: 0.17, green: 0.58, blue: 0.47),
                accent: Color(red: 0.20, green: 0.87, blue: 0.60),
                accentSecondary: Color(red: 0.36, green: 0.64, blue: 0.98),
                textPrimary: Color(red: 0.96, green: 0.96, blue: 0.95),
                textSecondary: Color(red: 0.70, green: 0.72, blue: 0.75),
                divider: Color.white.opacity(0.08),
                shadow: Color.black.opacity(0.22)
            )
        case .solar:
            ThemePalette(
                backgroundTop: Color(red: 0.96, green: 0.92, blue: 0.84),
                backgroundBottom: Color(red: 0.88, green: 0.82, blue: 0.72),
                cardFill: Color.white.opacity(0.46),
                cardTint: Color(red: 0.61, green: 0.39, blue: 0.22),
                accent: Color(red: 0.79, green: 0.45, blue: 0.17),
                accentSecondary: Color(red: 0.54, green: 0.27, blue: 0.18),
                textPrimary: Color(red: 0.22, green: 0.15, blue: 0.10),
                textSecondary: Color(red: 0.42, green: 0.31, blue: 0.22),
                divider: Color.black.opacity(0.08),
                shadow: Color.black.opacity(0.14)
            )
        case .mono:
            ThemePalette(
                backgroundTop: Color(red: 0.94, green: 0.94, blue: 0.94),
                backgroundBottom: Color(red: 0.83, green: 0.83, blue: 0.83),
                cardFill: Color.white.opacity(0.58),
                cardTint: Color(red: 0.18, green: 0.18, blue: 0.18),
                accent: Color.black.opacity(0.86),
                accentSecondary: Color.black.opacity(0.55),
                textPrimary: Color.black.opacity(0.88),
                textSecondary: Color.black.opacity(0.58),
                divider: Color.black.opacity(0.10),
                shadow: Color.black.opacity(0.12)
            )
        }
    }
}

struct EarnzaBackground: View {
    let palette: ThemePalette

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [palette.backgroundTop, palette.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            MeshBackdrop(palette: palette)
                .blendMode(.overlay)
                .opacity(0.42)
                .ignoresSafeArea()
        }
    }
}

private struct MeshBackdrop: View {
    let palette: ThemePalette

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let circles: [(CGPoint, CGFloat, Color)] = [
                    (CGPoint(x: size.width * 0.15, y: size.height * 0.18), 180, palette.accent.opacity(0.20)),
                    (CGPoint(x: size.width * 0.82, y: size.height * 0.25), 220, palette.accentSecondary.opacity(0.16)),
                    (CGPoint(x: size.width * 0.40, y: size.height * 0.82), 240, palette.cardTint.opacity(0.18))
                ]

                for circle in circles {
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: circle.0.x - circle.1 / 2,
                            y: circle.0.y - circle.1 / 2,
                            width: circle.1,
                            height: circle.1
                        )),
                        with: .radialGradient(
                            Gradient(colors: [circle.2, .clear]),
                            center: circle.0,
                            startRadius: 6,
                            endRadius: circle.1 / 1.9
                        )
                    )
                }

                var path = Path()
                let spacing: CGFloat = 28
                stride(from: 0, through: size.height, by: spacing).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                stride(from: 0, through: size.width, by: spacing).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(path, with: .color(palette.divider.opacity(0.22)), lineWidth: 0.5)
            }
        }
    }
}
