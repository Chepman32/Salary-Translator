import SwiftUI

struct OnboardingFlowView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette
    let onFinish: () -> Void
    @State private var selection = 0

    private var pages: [(title: String, subtitle: String, symbol: String, stat: String, statLabel: String)] {
        [
            (L10n.s("onboarding.page1.title", "See what your salary really means."), L10n.s("onboarding.page1.subtitle", "Translate income into time, objects, rent, and real-world context."), "sparkles.rectangle.stack", L10n.s("onboarding.page1.stat", "$0.43 / min"), L10n.s("onboarding.page1.label", "Coffee in 18.4 minutes")),
            (L10n.s("onboarding.page2.title", "See how long things really cost."), L10n.s("onboarding.page2.subtitle", "Translate any purchase into hours of your life."), "gamecontroller", L10n.s("onboarding.page2.stat", "6.2 hrs"), L10n.s("onboarding.page2.label", "PS5 costs you 6.2 hours of work")),
            (L10n.s("onboarding.page3.title", "Compare your pay across 50 cities."), L10n.s("onboarding.page3.subtitle", "Understand how far the same salary stretches elsewhere."), "building.2.crop.circle", L10n.s("onboarding.page3.stat", "3× further"), L10n.s("onboarding.page3.label", "Same salary, Austin vs. San Francisco")),
            (L10n.s("onboarding.page4.title", "Private by design."), L10n.s("onboarding.page4.subtitle", "All calculations stay on your device. No account required."), "lock.shield", L10n.s("onboarding.page4.stat", "100% local"), L10n.s("onboarding.page4.label", "Zero data ever leaves your device"))
        ]
    }

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
                    Group {
                        if index == 0 {
                            OnboardingSalaryPageView(
                                scenario: scenario,
                                settings: settings,
                                title: page.title,
                                subtitle: page.subtitle,
                                palette: palette
                            )
                        } else {
                            OnboardingPageView(
                                title: page.title,
                                subtitle: page.subtitle,
                                symbolName: page.symbol,
                                stat: page.stat,
                                statLabel: page.statLabel,
                                palette: palette
                            )
                        }
                    }
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

private struct OnboardingSalaryPageView: View {
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let title: String
    let subtitle: String
    let palette: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer(minLength: 16)

            OnboardingSalaryCard(scenario: scenario, settings: settings, palette: palette)

            Text(title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(palette.textPrimary)

            Text(subtitle)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(palette.textSecondary)
                .lineSpacing(4)

            Spacer(minLength: 16)
        }
    }
}

private struct OnboardingSalaryCard: View {
    @Environment(\.locale) private var locale
    @Bindable var scenario: Scenario
    @Bindable var settings: AppSettings
    let palette: ThemePalette

    private let fxRates = BundledDatasetRepository().fxRates

    var body: some View {
        GlassCard(palette: palette, padding: 26) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.s("salary_input.annual", "Annual"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(palette.textSecondary)
                            .textCase(.uppercase)

                        Text(EarnzaFormatters.currency(scenario.salaryAmount, code: scenario.currencyCode, maximumFractionDigits: 0))
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(palette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }

                    Spacer(minLength: 12)

                    Menu {
                        ForEach(CurrencyCatalog.orderedCodes(for: locale), id: \.self) { code in
                            Button {
                                applyCurrencyChange(code)
                            } label: {
                                if code == scenario.currencyCode {
                                    Label(code, systemImage: "checkmark")
                                } else {
                                    Text(code)
                                }
                            }
                        }
                    } label: {
                        Label(scenario.currencyCode, systemImage: "banknote")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(palette.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Capsule(style: .continuous).fill(palette.cardFill))
                    }
                }

                Text(L10n.s("salary_input.title", "Your salary, translated."))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(palette.textSecondary)

                Spacer(minLength: 4)

                Slider(
                    value: Binding(
                        get: { min(max(scenario.salaryAmount, sliderRange.lowerBound), sliderRange.upperBound) },
                        set: { newValue in
                            scenario.salaryAmount = newValue
                            scenario.payPeriodMode = .annual
                            scenario.touch()
                        }
                    ),
                    in: sliderRange
                )
                .tint(palette.accent)

                HStack {
                    Text(EarnzaFormatters.compactCurrency(sliderRange.lowerBound, code: scenario.currencyCode))
                    Spacer()
                    Text(EarnzaFormatters.compactCurrency(sliderRange.upperBound, code: scenario.currencyCode))
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.textSecondary)
            }
            .frame(height: 208, alignment: .top)
        }
        .onAppear {
            scenario.payPeriodMode = .annual
            scenario.touch()
        }
    }

    private var sliderRange: ClosedRange<Double> {
        let lower = convertedAnnualAmount(20_000, to: scenario.currencyCode)
        let upper = convertedAnnualAmount(500_000, to: scenario.currencyCode)
        return lower...upper
    }

    private func applyCurrencyChange(_ newCurrencyCode: String) {
        let previousCurrencyCode = scenario.currencyCode
        guard previousCurrencyCode != newCurrencyCode else { return }

        scenario.salaryAmount = roundedAnnualAmount(convertedAmount(scenario.salaryAmount, from: previousCurrencyCode, to: newCurrencyCode), currencyCode: newCurrencyCode)
        scenario.comparatorSalary = roundedAnnualAmount(convertedAmount(scenario.comparatorSalary, from: previousCurrencyCode, to: newCurrencyCode), currencyCode: newCurrencyCode)
        scenario.monthlyRent = roundedRecurringAmount(convertedAmount(scenario.monthlyRent, from: previousCurrencyCode, to: newCurrencyCode), currencyCode: newCurrencyCode)

        if scenario.manualTakeHomeAnnual > 0 {
            scenario.manualTakeHomeAnnual = roundedAnnualAmount(convertedAmount(scenario.manualTakeHomeAnnual, from: previousCurrencyCode, to: newCurrencyCode), currencyCode: newCurrencyCode)
        }

        scenario.currencyCode = newCurrencyCode
        settings.defaultCurrencyCode = newCurrencyCode
        scenario.touch()
    }

    private func convertedAmount(_ amount: Double, from sourceCode: String, to targetCode: String) -> Double {
        guard sourceCode != targetCode else { return amount }
        let sourceRate = fxRates.rates[sourceCode] ?? 1
        let targetRate = fxRates.rates[targetCode] ?? 1
        let usdValue = amount / max(sourceRate, 0.0001)
        return usdValue * targetRate
    }

    private func convertedAnnualAmount(_ usdAmount: Double, to currencyCode: String) -> Double {
        guard currencyCode != "USD" else { return usdAmount }
        return roundedAnnualAmount(convertedAmount(usdAmount, from: "USD", to: currencyCode), currencyCode: currencyCode)
    }

    private func roundedAnnualAmount(_ amount: Double, currencyCode: String) -> Double {
        max(annualRoundingStep(for: currencyCode), (amount / annualRoundingStep(for: currencyCode)).rounded() * annualRoundingStep(for: currencyCode))
    }

    private func roundedRecurringAmount(_ amount: Double, currencyCode: String) -> Double {
        max(recurringRoundingStep(for: currencyCode), (amount / recurringRoundingStep(for: currencyCode)).rounded() * recurringRoundingStep(for: currencyCode))
    }

    private func annualRoundingStep(for currencyCode: String) -> Double {
        switch currencyCode {
        case "JPY": 100_000
        case "RUB": 50_000
        case "THB": 10_000
        default: 100
        }
    }

    private func recurringRoundingStep(for currencyCode: String) -> Double {
        switch currencyCode {
        case "JPY": 10_000
        case "RUB": 1_000
        case "THB": 100
        default: 10
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
