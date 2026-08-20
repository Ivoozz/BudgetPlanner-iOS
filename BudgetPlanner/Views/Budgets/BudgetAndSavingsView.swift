import SwiftUI

public struct BudgetAndSavingsView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var selectedTab: Int = 0 // 0 = Budgetten, 1 = Spaardoelen
    @State private var showingAddBudgetSheet: Bool = false
    @State private var showingAddGoalSheet: Bool = false
    @State private var editingBudgetItem: CategoryBreakdownItem? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        // Month & Privacy Bar
                        MonthNavigationBar()

                        // Segmented Control
                        HStack(spacing: 0) {
                            tabButton(title: "Budgetplanner", index: 0, icon: "chart.pie.fill")
                            tabButton(title: "Spaardoelen", index: 1, icon: "target")
                        }
                        .padding(4)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())

                        if selectedTab == 0 {
                            budgetSectionView
                        } else {
                            savingsSectionView
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await store.refreshAll()
                }
            }
            .navigationTitle(selectedTab == 0 ? "Budgetplanner" : "Spaardoelen")
            .sheet(isPresented: $showingAddBudgetSheet) {
                EditBudgetSheet(item: editingBudgetItem)
            }
            .sheet(isPresented: $showingAddGoalSheet) {
                AddSavingsGoalSheet()
            }
        }
    }

    private func tabButton(title: String, index: Int, icon: String) -> some View {
        let isSelected = selectedTab == index
        return Button(action: {
            HapticManager.selection()
            withAnimation(.spring(response: 0.3)) {
                selectedTab = index
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.appEmerald : Color.clear)
            )
        }
    }

    // MARK: - Budget Section
    private var budgetSectionView: some View {
        VStack(spacing: 14) {
            HStack {
                Text("CATEGORIE BUDGETTEN")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.1)

                Spacer()

                Button(action: {
                    editingBudgetItem = nil
                    showingAddBudgetSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Budget Instellen")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appEmerald)
                }
            }

            if store.categoryBreakdown.isEmpty {
                VStack(spacing: 8) {
                    Text("Nog geen uitgaven of budgetten ingesteld voor deze maand.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .liquidGlass(cornerRadius: 18)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(store.categoryBreakdown) { item in
                        BudgetRowView(item: item)
                            .onTapGesture {
                                editingBudgetItem = item
                                showingAddBudgetSheet = true
                            }
                    }
                }
            }
        }
    }

    // MARK: - Savings Section
    private var savingsSectionView: some View {
        VStack(spacing: 14) {
            HStack {
                Text("SPAARBUFFERS & POTJES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.1)

                Spacer()

                Button(action: {
                    showingAddGoalSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Nieuw Spaardoel")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appEmerald)
                }
            }

            if store.savingsGoals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(size: 36))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Nog geen spaardoelen aangemaakt.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .liquidGlass(cornerRadius: 18)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(store.savingsGoals) { goal in
                        SavingsGoalCard(goal: goal)
                    }
                }
            }
        }
    }
}
