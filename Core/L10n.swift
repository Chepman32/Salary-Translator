import Foundation

enum L10n {
    static func s(_ key: String, _ fallback: String) -> String {
        if let supplementalLanguageKey,
           let value = LocalizationCatalog.supplementalTranslations[supplementalLanguageKey]?[key] {
            return value
        }
        let localizedValue = localizationBundle()?.localizedString(forKey: key, value: nil, table: nil)
        if let value = LocalizationCatalog.supplementalTranslations["en"]?[key],
           localizedValue == key {
            return value
        }
        return localizationBundle()?.localizedString(forKey: key, value: fallback, table: nil) ?? fallback
    }

    static func f(_ key: String, _ fallback: String, _ args: CVarArg...) -> String {
        String(format: s(key, fallback), locale: locale, arguments: args)
    }

    static func bundledObjectName(id: String, fallback: String) -> String {
        switch id {
        case "big-mac": s("object.big_mac.name", "Big Mac")
        case "coffee": s("object.coffee.name", "Coffee")
        case "grocery-basket": s("object.grocery_basket.name", "Grocery Basket")
        case "ps5": s("object.ps5.name", "PS5")
        case "iphone": s("object.iphone.name", "iPhone")
        case "airpods": s("object.airpods.name", "AirPods Pro")
        case "rent-day": s("object.rent_day.name", "Rent Day")
        case "streaming": s("object.streaming.name", "Streaming Month")
        case "cinema": s("object.cinema.name", "Cinema Ticket")
        case "flight": s("object.flight.name", "Intercity Flight")
        case "sneakers": s("object.sneakers.name", "Sneakers")
        case "gym": s("object.gym.name", "Gym Membership")
        case "taxi": s("object.taxi.name", "Taxi Ride")
        case "energy-bill": s("object.energy_bill.name", "Energy Bill Chunk")
        default: fallback
        }
    }

    static func bundledObjectSupportingLine(id: String, fallback: String) -> String {
        switch id {
        case "big-mac": s("object.big_mac.line", "Fast benchmark for everyday purchasing power.")
        case "coffee": s("object.coffee.line", "A tiny recurring indulgence with instant meaning.")
        case "grocery-basket": s("object.grocery_basket.line", "A one-trip household grocery reset.")
        case "ps5": s("object.ps5.line", "A clean benchmark for one-off discretionary spend.")
        case "iphone": s("object.iphone.line", "A premium consumer tech anchor.")
        case "airpods": s("object.airpods.line", "A compact splurge with recognizable value.")
        case "rent-day": s("object.rent_day.line", "One day of housing pressure.")
        case "streaming": s("object.streaming.line", "A recurring convenience subscription.")
        case "cinema": s("object.cinema.line", "A small leisure benchmark.")
        case "flight": s("object.flight.line", "A quick mobility escape.")
        case "sneakers": s("object.sneakers.line", "A mainstream style purchase.")
        case "gym": s("object.gym.line", "A monthly routine expense.")
        case "taxi": s("object.taxi.line", "A convenience vs time trade-off.")
        case "energy-bill": s("object.energy_bill.line", "A monthly household utility pulse.")
        default: fallback
        }
    }

    static func bundledCityNote(id: String, fallback: String) -> String {
        switch id {
        case "new-york-us": s("city.new_york.note", "High income, high pressure.")
        case "berlin-de": s("city.berlin.note", "Balanced costs with strong transit.")
        case "warsaw-pl": s("city.warsaw.note", "Strong stretch profile.")
        default: fallback
        }
    }

    static var locale: Locale {
        guard let effectiveAppLanguage else { return .current }
        return Locale(identifier: effectiveAppLanguage.localeIdentifier ?? Locale.current.identifier)
    }

    private static func localizationBundle() -> Bundle? {
        let code = effectiveAppLanguage?.localeIdentifier
        let bundleCode = code == "no" ? "nb" : code
        guard let bundleCode,
              let path = Bundle.main.path(forResource: bundleCode, ofType: "lproj")
        else { return Bundle.main }
        return Bundle(path: path) ?? Bundle.main
    }

    private static var effectiveAppLanguage: AppLanguage? {
        guard let rawValue = UserDefaults.standard.string(forKey: AppLanguage.storageKey),
              let language = AppLanguage(rawValue: rawValue)
        else {
            return preferredSystemLanguage
        }
        if language == .system {
            return preferredSystemLanguage
        }
        return language
    }

    private static var supplementalLanguageKey: String? {
        effectiveAppLanguage?.rawValue
    }

    private static var preferredSystemLanguage: AppLanguage? {
        Locale.preferredLanguages.lazy.compactMap(resolveLanguage).first
    }

    private static func resolveLanguage(from identifier: String) -> AppLanguage? {
        if let directMatch = AppLanguage(rawValue: identifier) {
            return directMatch
        }

        let normalized = identifier.replacingOccurrences(of: "_", with: "-")
        if normalized.hasPrefix("zh-Hans") { return .zhHans }
        if normalized.hasPrefix("es-MX") { return .esMX }
        if normalized.hasPrefix("pt-BR") { return .ptBR }
        if normalized.hasPrefix("nb") || normalized.hasPrefix("no") { return .no }

        let languageCode = Locale(identifier: normalized).language.languageCode?.identifier
            ?? normalized.split(separator: "-").first.map(String.init)

        return switch languageCode {
        case "en": .en
        case "ja": .ja
        case "ko": .ko
        case "de": .de
        case "fr": .fr
        case "ar": .ar
        case "ru": .ru
        case "it": .it
        case "nl": .nl
        case "tr": .tr
        case "th": .th
        case "vi": .vi
        case "id": .id
        case "pl": .pl
        case "uk": .uk
        case "hi": .hi
        case "he": .he
        case "sv": .sv
        case "da": .da
        case "fi": .fi
        case "cs": .cs
        case "hu": .hu
        case "ro": .ro
        case "el": .el
        case "ms": .ms
        case "fil": .fil
        default: nil
        }
    }
}
