import SwiftUI

public struct BudgetsView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var selectedItemForEdit: CategoryBreakdownItem? = nil

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
                Color(hex: "#090D16").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Overview Card
                        VStack(spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TOTAAL GEBUDGETTEERD")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.gray)

                                    Text(CurrencyFormatter.format(totalBudgeted))
                                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("TOTAAL UITGEGEVEN")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.gray)

                                    Text(CurrencyFormatter.format(totalSpent))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(totalSpent > totalBudgeted && totalBudgeted > 0 ? .appRose : .appEmerald)
                                }
                            }
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 20, strokeColor: Color.appSapphire.opacity(0.3))

                        // Category List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CATEGORIEËN & LIMIETEN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)
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
                                VStack(spacing: 10) {
                                    ForEach(store.categoryBreakdown) { item in
                                        BudgetRowView(item: item) {
                                            selectedItemForEdit = item
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
            .sheet(item: $selectedItemForEdit) { item in
                EditBudgetSheet(categoryItem: item)
            }
        }
    }
}
