import SwiftUI

struct OnboardingFlowView: View {
    let palette: ThemePalette
    let onFinish: () -> Void
    @State private var selection = 0

    private let pages: [(title: String, subtitle: String, symbol: String, stat: String, statLabel: String)] = [
        (L10n.s("onboarding.page1.title", "See what your salary really means."), L10n.s("onboarding.page1.subtitle", "Translate income into time, objects, rent, and real-world context."), "sparkles.rectangle.stack", L10n.s("onboarding.page1.stat", "$0.43 / min"), L10n.s("onboarding.page1.label", "Coffee in 18.4 minutes")),
        (L10n.s("onboarding.page2.title", "See how long things really cost."), L10n.s("onboarding.page2.subtitle", "Translate any purchase into hours of your life."), "gamecontroller", L10n.s("onboarding.page2.stat", "6.2 hrs"), L10n.s("onboarding.page2.label", "PS5 costs you 6.2 hours of work")),
        (L10n.s("onboarding.page3.title", "Compare your pay across 50 cities."), L10n.s("onboarding.page3.subtitle", "Understand how far the same salary stretches elsewhere."), "building.2.crop.circle", L10n.s("onboarding.page3.stat", "3× further"), L10n.s("onboarding.page3.label", "Same salary, Austin vs. San Francisco")),
        (L10n.s("onboarding.page4.title", "Private by design."), L10n.s("onboarding.page4.subtitle", "All calculations stay on your device. No account required."), "lock.shield", L10n.s("onboarding.page4.stat", "100% local"), L10n.s("onboarding.page4.label", "Zero data ever leaves your device"))
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(L10n.s("common.skip", "Skip"), action: onFinish)
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

                Button(selection == pages.count - 1 ? L10n.s("onboarding.cta.finish", "Translate My Salary") : L10n.s("common.continue", "Continue")) {
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
