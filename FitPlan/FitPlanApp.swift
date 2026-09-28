import SwiftUI

@main
struct FitPlanApp: App {
    @StateObject private var store = TrainingStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .tint(AppTheme.accent)
        }
    }
}

