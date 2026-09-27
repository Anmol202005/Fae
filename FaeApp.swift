import SwiftUI
import SwiftData

@main
struct FaeApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [Transaction.self, AppData.self])
    }
}
