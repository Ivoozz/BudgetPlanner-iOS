import SwiftUI

public struct SavingsView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var showingAddGoalSheet: Bool = false
    @State private var selectedGoalForContribute: SavingsGoal? = nil

    public init() {}

    private var totalSaved: Double {
        store.savingsGoals.reduce(0) { $0 + $1.currentAmount }
    }

    private var totalTarget: Double {
        store.savingsGoals.reduce(0) { $0 + $1.targetAmount }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        // Month & Privacy Bar
                        MonthNavigationBar()

                        // Total Savings Hero Card
                        VStack(spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TOTAAL GESPAARD IN DOELEN")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray)

                                    Text(CurrencyFormatter.format(totalSaved, privacy: store.privacyMode))
                                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                                        .foregroundColor(.appEmerald)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("DOELBEDRAG")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray)

                                    Text(CurrencyFormatter.format(totalTarget, privacy: store.privacyMode))
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 20, strokeColor: Color.appEmerald.opacity(0.35))

                        // Savings Goals Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("SPAARDOELEN")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                    .tracking(1.1)

                                Spacer()

                                Button(action: { showingAddGoalSheet = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus")
                                        Text("Nieuw doel")
                                    }
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appEmerald)
                                }
                            }
                            .padding(.horizontal, 4)

                            if store.savingsGoals.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "target")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray)
                                        Text("Nog geen spaardoelen aangemaakt")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(24)
                                    Spacer()
                                }
                                .liquidGlass(cornerRadius: 16)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(store.savingsGoals) { goal in
                                        SavingsGoalCard(goal: goal)
                                    }
                                }
                            }
                        }

                        // Upcoming Bills Section
                        UpcomingBillsSection(bills: store.upcomingBills)

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await store.refreshAll()
                }
            }
            .navigationTitle("Sparen & Vaste Lasten")
            .sheet(isPresented: $showingAddGoalSheet) {
                AddSavingsGoalSheet()
            }
            .sheet(item: $selectedGoalForContribute) { goal in
                ContributeSavingsSheet(goal: goal)
            }
        }
    }
}
