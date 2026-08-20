import SwiftUI

public struct BudgetsView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var selectedItemForEdit: CategoryBreakdownItem? = nil
    @State private var showingEditSheet: Bool = false

    public init() {}

    private var totalBudgeted: Double {
        store.categoryBreakdown.compactMap { $0.budgetAmount }.reduce(0, +)
    }

    private var totalSpent: Double {
        store.categoryBreakdown.reduce(0) { $0 + $1.totalAmount }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        // Month & Privacy Bar
                        MonthNavigationBar()

                        // Overview Card
                        VStack(spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TOTAAL GEBUDGETTEERD")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray)

                                    Text(CurrencyFormatter.format(totalBudgeted, privacy: store.privacyMode))
                                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("TOTAAL UITGEGEVEN")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray)

                                    Text(CurrencyFormatter.format(totalSpent, privacy: store.privacyMode))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(totalSpent > totalBudgeted && totalBudgeted > 0 ? .appRose : .appEmerald)
                                }
                            }
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 20, strokeColor: Color.appSapphire.opacity(0.3))

                        // Category List
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("CATEGORIEËN & LIMIETEN")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                    .tracking(1.1)

                                Spacer()

                                Button(action: {
                                    selectedItemForEdit = nil
                                    showingEditSheet = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Budget Toevoegen")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.appEmerald)
                                }
                            }
                            .padding(.horizontal, 4)

                            if store.categoryBreakdown.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("Geen budgetten ingesteld")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(30)
                                    Spacer()
                                }
                                .liquidGlass(cornerRadius: 16)
                            } else {
                                LazyVStack(spacing: 10) {
                                    ForEach(store.categoryBreakdown) { item in
                                        BudgetRowView(item: item) {
                                            selectedItemForEdit = item
                                            showingEditSheet = true
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await store.refreshAll()
                }
            }
            .navigationTitle("Budgetten")
            .sheet(isPresented: $showingEditSheet) {
                EditBudgetSheet(item: selectedItemForEdit)
            }
        }
    }
}
