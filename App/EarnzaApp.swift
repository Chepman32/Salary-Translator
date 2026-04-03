import SwiftData
import SwiftUI

@main
struct EarnzaApp: App {
    private let container: ModelContainer = {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing-reset")
        let schema = Schema([
            Scenario.self,
            AppSettings.self
        ])

        let configuration: ModelConfiguration
        if isUITesting {
            configuration = ModelConfiguration("Earnza", schema: schema, isStoredInMemoryOnly: true)
        } else {
            configuration = ModelConfiguration("Earnza", schema: schema, url: Self.storeURL)
        }

        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            guard !isUITesting else {
                fatalError("Failed to create model container: \(error.localizedDescription)")
            }

            Self.destroyPersistentStore()

            do {
                return try ModelContainer(for: schema, configurations: configuration)
            } catch {
                fatalError("Failed to recreate model container after reset: \(error.localizedDescription)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            EarnzaRootView()
        }
        .modelContainer(container)
    }

    private static var storeURL: URL {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true, attributes: nil)
        return appSupportURL.appendingPathComponent("default.store")
    }

    private static func destroyPersistentStore() {
        let fileManager = FileManager.default
        let storeURL = Self.storeURL
        let companionURLs = [
            storeURL,
            URL(fileURLWithPath: storeURL.path + "-shm"),
            URL(fileURLWithPath: storeURL.path + "-wal")
        ]

        for url in companionURLs where fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}
