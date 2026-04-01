import SwiftUI

struct OnboardingFlowView: View {
    let palette: ThemePalette
    let onFinish: () -> Void
    @State private var selection = 0

    private let pages: [(title: String, subtitle: String, symbol: String, stat: String, statLabel: String)] = [
        ("See what your salary really means.", "Translate income into time, objects, rent, and real-world context.", "sparkles.rectangle.stack", "$0.43 / min", "Coffee in 18.4 minutes"),
        ("See how long things really cost.", "Translate any purchase into hours of your life.", "gamecontroller", "6.2 hrs", "PS5 costs you 6.2 hours of work"),
        ("Compare your pay across 50 cities.", "Understand how far the same salary stretches elsewhere.", "building.2.crop.circle", "3× further", "Same salary, Austin vs. San Francisco"),
        ("Private by design.", "All calculations stay on your device. No account required.", "lock.shield", "100% local", "Zero data ever leaves your device")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip", action: onFinish)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)

            TabView(selection: $selection) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(
                        title: page.title,
                        subtitle: page.subtitle,
                        symbolName: page.symbol,
                        stat: page.stat,
                        statLabel: page.statLabel,
                        palette: palette
                    )
                    .padding(.horizontal, 24)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule(style: .continuous)
                            .fill(index == selection ? palette.accent : palette.divider)
                            .frame(width: index == selection ? 34 : 18, height: 4)
                            .animation(.spring(response: 0.32, dampingFraction: 0.82), value: selection)
                    }
                }

                Button(selection == pages.count - 1 ? "Translate My Salary" : "Continue") {
                    if selection == pages.count - 1 {
                        onFinish()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                            selection += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(palette.accent)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }
}

private struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let symbolName: String
    let stat: String
    let statLabel: String
    let palette: ThemePalette
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer(minLength: 16)

            GlassCard(palette: palette, padding: 26) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [palette.accent.opacity(0.18), palette.accentSecondary.opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 18) {
                        Image(systemName: symbolName)
                            .font(.system(size: 46, weight: .medium))
                            .foregroundStyle(palette.accent)
                            .scaleEffect(animate ? 1.08 : 0.92)

                        VStack(spacing: 8) {
                            Text(stat)
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .monospacedDigit()
                            Text(statLabel)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(palette.textSecondary)
                        }
                    }
                    .foregroundStyle(palette.textPrimary)
                }
                .frame(height: 260)
            }

            Text(title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(palette.textPrimary)

            Text(subtitle)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(palette.textSecondary)
                .lineSpacing(4)

            Spacer(minLength: 16)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
