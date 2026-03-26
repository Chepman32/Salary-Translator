import SwiftData
import SwiftUI

@main
struct PayloApp: App {
    private let container: ModelContainer = {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing-reset")
        do {
            let schema = Schema([
                Scenario.self,
                AppSettings.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create model container: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            PayloRootView()
        }
        .modelContainer(container)
    }
}
