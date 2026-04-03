import Foundation

enum EarnzaFormatters {
    static func currency(
        _ value: Double,
        code: String,
        maximumFractionDigits: Int = 2,
        minimumFractionDigits: Int = 0
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.locale = locale(forCurrencyCode: code)
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func compactCurrency(_ value: Double, code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 1
        formatter.locale = locale(forCurrencyCode: code)
        formatter.usesSignificantDigits = false
        formatter.maximumIntegerDigits = 4

        if abs(value) >= 1_000_000 {
            return currency(value / 1_000_000, code: code, maximumFractionDigits: 1) + "M"
        }
        if abs(value) >= 1_000 {
            return currency(value / 1_000, code: code, maximumFractionDigits: 1) + "K"
        }
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func decimal(_ value: Double, fractionDigits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = 0
        formatter.locale = L10n.locale
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func percent(_ value: Double, fractionDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = 0
        formatter.locale = L10n.locale
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func duration(hours: Double) -> String {
        if hours < 1 {
            return "\(Int((hours * 60).rounded())) min"
        }
        if hours < 8 {
            return "\(decimal(hours, fractionDigits: 1)) hrs"
        }
        return "\(decimal(hours / 8, fractionDigits: 1)) workdays"
    }

    static func locale(forCurrencyCode code: String) -> Locale {
        Locale.availableIdentifiers
            .lazy
            .compactMap { Locale(identifier: $0) }
            .first(where: { $0.currency?.identifier == code }) ?? L10n.locale
    }
}
