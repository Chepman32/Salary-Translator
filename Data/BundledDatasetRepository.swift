import Foundation

final class BundledDatasetRepository: DatasetRepository {
    let cities: [CityDatasetEntry]
    let objectCatalog: [ObjectPreset]
    let fxRates: FXRates

    init(bundle: Bundle = .main) {
        self.cities = Self.load("cities", extension: "json", from: bundle, fallback: Self.fallbackCities)
            .map(Self.localizedCity)
        self.objectCatalog = Self.load("objects", extension: "json", from: bundle, fallback: Self.fallbackObjects)
            .map(Self.localizedObject)
        self.fxRates = Self.load("fx_rates", extension: "json", from: bundle, fallback: FXRates(base: "USD", rates: Self.fallbackRates))
    }

    private static func load<T: Decodable>(_ resource: String, extension ext: String, from bundle: Bundle, fallback: T) -> T {
        guard let url = bundle.url(forResource: resource, withExtension: ext),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(T.self, from: data)
        else {
            return fallback
        }
        return decoded
    }

    private static let fallbackRates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.78,
        "JPY": 151.0,
        "AED": 3.67,
        "PLN": 3.95,
        "THB": 35.6,
        "SGD": 1.34,
        "AUD": 1.52,
        "CAD": 1.36,
        "RUB": 90.0
    ]

    private static let fallbackObjects: [ObjectPreset] = [
        .init(id: "big-mac", localizedName: "Big Mac", category: .food, iconName: "fork.knife", defaultPrice: 6.5, currencyCode: "USD", editableByUser: true, sharePriority: 1, supportingLine: "Fast benchmark for everyday purchasing power."),
        .init(id: "coffee", localizedName: "Coffee", category: .food, iconName: "cup.and.saucer", defaultPrice: 4.8, currencyCode: "USD", editableByUser: true, sharePriority: 1, supportingLine: "A tiny recurring indulgence with instant meaning."),
        .init(id: "grocery-basket", localizedName: "Grocery Basket", category: .food, iconName: "cart", defaultPrice: 82, currencyCode: "USD", editableByUser: true, sharePriority: 2, supportingLine: "A one-trip household grocery reset."),
        .init(id: "ps5", localizedName: "PS5", category: .tech, iconName: "gamecontroller", defaultPrice: 499, currencyCode: "USD", editableByUser: true, sharePriority: 1, supportingLine: "A clean benchmark for one-off discretionary spend."),
        .init(id: "iphone", localizedName: "iPhone", category: .tech, iconName: "iphone.gen3", defaultPrice: 999, currencyCode: "USD", editableByUser: true, sharePriority: 1, supportingLine: "A premium consumer tech anchor."),
        .init(id: "airpods", localizedName: "AirPods Pro", category: .tech, iconName: "airpodspro", defaultPrice: 249, currencyCode: "USD", editableByUser: true, sharePriority: 2, supportingLine: "A compact splurge with recognizable value."),
        .init(id: "rent-day", localizedName: "Rent Day", category: .housing, iconName: "house", defaultPrice: 80, currencyCode: "USD", editableByUser: true, sharePriority: 1, supportingLine: "One day of housing pressure."),
        .init(id: "streaming", localizedName: "Streaming Month", category: .bills, iconName: "play.rectangle", defaultPrice: 16, currencyCode: "USD", editableByUser: true, sharePriority: 3, supportingLine: "A recurring convenience subscription."),
        .init(id: "cinema", localizedName: "Cinema Ticket", category: .lifestyle, iconName: "ticket", defaultPrice: 18, currencyCode: "USD", editableByUser: true, sharePriority: 3, supportingLine: "A small leisure benchmark."),
        .init(id: "flight", localizedName: "Intercity Flight", category: .travel, iconName: "airplane", defaultPrice: 280, currencyCode: "USD", editableByUser: true, sharePriority: 2, supportingLine: "A quick mobility escape."),
        .init(id: "sneakers", localizedName: "Sneakers", category: .lifestyle, iconName: "shoeprints.fill", defaultPrice: 130, currencyCode: "USD", editableByUser: true, sharePriority: 3, supportingLine: "A mainstream style purchase."),
        .init(id: "gym", localizedName: "Gym Membership", category: .lifestyle, iconName: "figure.strengthtraining.traditional", defaultPrice: 55, currencyCode: "USD", editableByUser: true, sharePriority: 3, supportingLine: "A monthly routine expense."),
        .init(id: "taxi", localizedName: "Taxi Ride", category: .transport, iconName: "car.side", defaultPrice: 28, currencyCode: "USD", editableByUser: true, sharePriority: 3, supportingLine: "A convenience vs time trade-off."),
        .init(id: "energy-bill", localizedName: "Energy Bill Chunk", category: .bills, iconName: "bolt.house", defaultPrice: 120, currencyCode: "USD", editableByUser: true, sharePriority: 2, supportingLine: "A monthly household utility pulse.")
    ]

    private static let fallbackCities: [CityDatasetEntry] = [
        .init(id: "new-york-us", cityName: "New York", countryName: "United States", region: "North America", rentIndex: 1.00, basketIndex: 1.00, burgerPrice: 7.5, coffeePrice: 5.7, techIndex: 1.05, stretchScore: 78, notes: "High income, high pressure.", datasetVersion: "2026.03"),
        .init(id: "berlin-de", cityName: "Berlin", countryName: "Germany", region: "Europe", rentIndex: 0.63, basketIndex: 0.78, burgerPrice: 6.8, coffeePrice: 4.2, techIndex: 0.94, stretchScore: 89, notes: "Balanced costs with strong transit.", datasetVersion: "2026.03"),
        .init(id: "warsaw-pl", cityName: "Warsaw", countryName: "Poland", region: "Europe", rentIndex: 0.42, basketIndex: 0.54, burgerPrice: 4.8, coffeePrice: 3.1, techIndex: 0.88, stretchScore: 96, notes: "Strong stretch profile.", datasetVersion: "2026.03")
    ]

    private static func localizedObject(_ object: ObjectPreset) -> ObjectPreset {
        ObjectPreset(
            id: object.id,
            localizedName: L10n.bundledObjectName(id: object.id, fallback: object.localizedName),
            category: object.category,
            iconName: object.iconName,
            defaultPrice: object.defaultPrice,
            currencyCode: object.currencyCode,
            editableByUser: object.editableByUser,
            sharePriority: object.sharePriority,
            supportingLine: L10n.bundledObjectSupportingLine(id: object.id, fallback: object.supportingLine)
        )
    }

    private static func localizedCity(_ city: CityDatasetEntry) -> CityDatasetEntry {
        CityDatasetEntry(
            id: city.id,
            cityName: L10n.bundledCityName(id: city.id, fallback: city.cityName),
            countryName: L10n.bundledCountryName(id: city.id, fallback: city.countryName),
            region: city.region,
            rentIndex: city.rentIndex,
            basketIndex: city.basketIndex,
            burgerPrice: city.burgerPrice,
            coffeePrice: city.coffeePrice,
            techIndex: city.techIndex,
            stretchScore: city.stretchScore,
            notes: L10n.bundledCityNote(id: city.id, fallback: city.notes),
            datasetVersion: city.datasetVersion
        )
    }
}
