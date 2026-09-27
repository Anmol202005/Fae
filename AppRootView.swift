import SwiftUI
import SwiftData

struct AppRootView: View {

    @Environment(\.modelContext) private var modelContext

    var body: some View {

        ContentView()
            .task {
                setupAppData()
            }
    }

    func setupAppData() {

        let data = AppData.current(in: modelContext)
        data.resetExpiredPeriods()

        try? modelContext.save()
    }
}
