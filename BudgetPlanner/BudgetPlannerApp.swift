import SwiftUI

@main
struct BudgetPlannerApp: App {
    @StateObject private var auth = AuthManager.shared
    @StateObject private var store = BudgetStore.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}
