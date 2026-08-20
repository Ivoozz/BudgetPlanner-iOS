import SwiftUI

public struct MainTabView: View {
    @ObservedObject var auth = AuthManager.shared
    @ObservedObject var store = BudgetStore.shared

    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        Group {
            if !auth.isAuthenticated {
                LoginView()
            } else {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "gauge.with.needle")
                        }
                        .tag(0)

                    TransactionsView()
                        .tabItem {
                            Label("Transacties", systemImage: "list.bullet.rectangle.portrait.fill")
                        }
                        .tag(1)

                    BudgetsView()
                        .tabItem {
                            Label("Budgetten", systemImage: "chart.bar.xaxis")
                        }
                        .tag(2)

                    SavingsView()
                        .tabItem {
                            Label("Sparen", systemImage: "target")
                        }
                        .tag(3)

                    SettingsView()
                        .tabItem {
                            Label("Instellingen", systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
                .tint(.appEmerald)
                .task {
                    await store.refreshAll()
                }
            }
        }
    }
}
