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

    static func bundledCityName(id: String, fallback: String) -> String {
        switch locale.language.languageCode?.identifier {
        case "ru":
            return switch id {
            case "new-york-us": "Нью-Йорк"
            case "san-francisco-us": "Сан-Франциско"
            case "seattle-us": "Сиэтл"
            case "austin-us": "Остин"
            case "miami-us": "Майами"
            case "toronto-ca": "Торонто"
            case "vancouver-ca": "Ванкувер"
            case "mexico-city-mx": "Мехико"
            case "london-gb": "Лондон"
            case "manchester-gb": "Манчестер"
            case "dublin-ie": "Дублин"
            case "amsterdam-nl": "Амстердам"
            case "berlin-de": "Берлин"
            case "munich-de": "Мюнхен"
            case "paris-fr": "Париж"
            case "lisbon-pt": "Лиссабон"
            case "madrid-es": "Мадрид"
            case "barcelona-es": "Барселона"
            case "rome-it": "Рим"
            case "milan-it": "Милан"
            case "zurich-ch": "Цюрих"
            case "vienna-at": "Вена"
            case "prague-cz": "Прага"
            case "warsaw-pl": "Варшава"
            case "budapest-hu": "Будапешт"
            case "athens-gr": "Афины"
            case "dubai-ae": "Дубай"
            case "abu-dhabi-ae": "Абу-Даби"
            case "doha-qa": "Доха"
            case "riyadh-sa": "Эр-Рияд"
            case "singapore-sg": "Сингапур"
            case "tokyo-jp": "Токио"
            case "osaka-jp": "Осака"
            case "seoul-kr": "Сеул"
            case "hong-kong-hk": "Гонконг"
            case "bangkok-th": "Бангкок"
            case "kuala-lumpur-my": "Куала-Лумпур"
            case "jakarta-id": "Джакарта"
            case "bengaluru-in": "Бенгалуру"
            case "mumbai-in": "Мумбаи"
            case "sydney-au": "Сидней"
            case "melbourne-au": "Мельбурн"
            case "auckland-nz": "Окленд"
            case "cape-town-za": "Кейптаун"
            case "johannesburg-za": "Йоханнесбург"
            case "nairobi-ke": "Найроби"
            case "lagos-ng": "Лагос"
            case "sao-paulo-br": "Сан-Паулу"
            case "rio-de-janeiro-br": "Рио-де-Жанейро"
            case "buenos-aires-ar": "Буэнос-Айрес"
            case "santiago-cl": "Сантьяго"
            case "bogota-co": "Богота"
            default: fallback
            }
        case "th":
            return switch id {
            case "new-york-us": "นิวยอร์ก"
            case "san-francisco-us": "ซานฟรานซิสโก"
            case "seattle-us": "ซีแอตเทิล"
            case "austin-us": "ออสติน"
            case "miami-us": "ไมอามี"
            case "toronto-ca": "โตรอนโต"
            case "vancouver-ca": "แวนคูเวอร์"
            case "mexico-city-mx": "เม็กซิโกซิตี"
            case "london-gb": "ลอนดอน"
            case "manchester-gb": "แมนเชสเตอร์"
            case "dublin-ie": "ดับลิน"
            case "amsterdam-nl": "อัมสเตอร์ดัม"
            case "berlin-de": "เบอร์ลิน"
            case "munich-de": "มิวนิก"
            case "paris-fr": "ปารีส"
            case "lisbon-pt": "ลิสบอน"
            case "madrid-es": "มาดริด"
            case "barcelona-es": "บาร์เซโลนา"
            case "rome-it": "โรม"
            case "milan-it": "มิลาน"
            case "zurich-ch": "ซูริก"
            case "vienna-at": "เวียนนา"
            case "prague-cz": "ปราก"
            case "warsaw-pl": "วอร์ซอ"
            case "budapest-hu": "บูดาเปสต์"
            case "athens-gr": "เอเธนส์"
            case "dubai-ae": "ดูไบ"
            case "abu-dhabi-ae": "อาบูดาบี"
            case "doha-qa": "โดฮา"
            case "riyadh-sa": "ริยาด"
            case "singapore-sg": "สิงคโปร์"
            case "tokyo-jp": "โตเกียว"
            case "osaka-jp": "โอซาก้า"
            case "seoul-kr": "โซล"
            case "hong-kong-hk": "ฮ่องกง"
            case "bangkok-th": "กรุงเทพฯ"
            case "kuala-lumpur-my": "กัวลาลัมเปอร์"
            case "jakarta-id": "จาการ์ตา"
            case "bengaluru-in": "เบงกาลูรู"
            case "mumbai-in": "มุมไบ"
            case "sydney-au": "ซิดนีย์"
            case "melbourne-au": "เมลเบิร์น"
            case "auckland-nz": "โอ๊คแลนด์"
            case "cape-town-za": "เคปทาวน์"
            case "johannesburg-za": "โจฮันเนสเบิร์ก"
            case "nairobi-ke": "ไนโรบี"
            case "lagos-ng": "ลากอส"
            case "sao-paulo-br": "เซาเปาลู"
            case "rio-de-janeiro-br": "รีโอเดจาเนโร"
            case "buenos-aires-ar": "บัวโนสไอเรส"
            case "santiago-cl": "ซันติอาโก"
            case "bogota-co": "โบโกตา"
            default: fallback
            }
        default:
            return fallback
        }
    }

    static func bundledCountryName(id: String, fallback: String) -> String {
        guard let regionCode = cityRegionCode(for: id) else { return fallback }
        return locale.localizedString(forRegionCode: regionCode) ?? fallback
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

    private static func cityRegionCode(for id: String) -> String? {
        switch id {
        case "new-york-us", "san-francisco-us", "seattle-us", "austin-us", "miami-us": "US"
        case "toronto-ca", "vancouver-ca": "CA"
        case "mexico-city-mx": "MX"
        case "london-gb", "manchester-gb": "GB"
        case "dublin-ie": "IE"
        case "amsterdam-nl": "NL"
        case "berlin-de", "munich-de": "DE"
        case "paris-fr": "FR"
        case "lisbon-pt": "PT"
        case "madrid-es", "barcelona-es": "ES"
        case "rome-it", "milan-it": "IT"
        case "zurich-ch": "CH"
        case "vienna-at": "AT"
        case "prague-cz": "CZ"
        case "warsaw-pl": "PL"
        case "budapest-hu": "HU"
        case "athens-gr": "GR"
        case "dubai-ae", "abu-dhabi-ae": "AE"
        case "doha-qa": "QA"
        case "riyadh-sa": "SA"
        case "singapore-sg": "SG"
        case "tokyo-jp", "osaka-jp": "JP"
        case "seoul-kr": "KR"
        case "hong-kong-hk": "HK"
        case "bangkok-th": "TH"
        case "kuala-lumpur-my": "MY"
        case "jakarta-id": "ID"
        case "bengaluru-in", "mumbai-in": "IN"
        case "sydney-au", "melbourne-au": "AU"
        case "auckland-nz": "NZ"
        case "cape-town-za", "johannesburg-za": "ZA"
        case "nairobi-ke": "KE"
        case "lagos-ng": "NG"
        case "sao-paulo-br", "rio-de-janeiro-br": "BR"
        case "buenos-aires-ar": "AR"
        case "santiago-cl": "CL"
        case "bogota-co": "CO"
        default: nil
        }
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
