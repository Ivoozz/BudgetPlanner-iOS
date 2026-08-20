import SwiftUI

public struct DashboardView: View {
    @ObservedObject var store = BudgetStore.shared
    @ObservedObject var auth = AuthManager.shared

    @State private var showingAddTransaction = false
    @State private var showingTransfer = false
    @State private var selectedTxType: TransactionType = .variableExpense

    public init() {}

    private var monthName: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "nl_NL")
        let symbols = df.monthSymbols ?? []
        let idx = store.selectedMonth - 1
        if idx >= 0 && idx < symbols.count {
            return "\(symbols[idx].capitalized) \(store.selectedYear)"
        }
        return "\(store.selectedMonth)-\(store.selectedYear)"
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#090D16").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        // 1. Month Selector Bar
                        monthSelectorBar

                        // 2. Hero Month Summary Card
                        HeroBalanceCard(summary: store.monthSummary)

                        // 3. Quick Action Buttons
                        quickActionGrid

                        // 4. Daily Spending Allowance
                        DailyBudgetCard(
                            dailyAmount: store.monthSummary.dailyBudgetRemaining,
                            daysLeft: store.monthSummary.daysLeftInMonth
                        )

                        // 5. Account Balances Carousel
                        if !store.accounts.isEmpty {
                            AccountCarouselView(accounts: store.accounts)
                        }

                        // 6. Budget Alerts / Top Categories
                        if !store.categoryBreakdown.isEmpty {
                            topCategoriesSection
                        }

                        // 7. Recent Transactions List
                        recentTransactionsSection

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    HapticManager.impact(.light)
                    await store.refreshAll()
                }

                // Floating Fast Action Button (Quick Add)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedTxType = .variableExpense
                            showingAddTransaction = true
                            HapticManager.impact(.medium)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appEmerald, Color(hex: "#059669")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 58, height: 58)
                                    .shadow(color: Color.appEmerald.opacity(0.4), radius: 12, x: 0, y: 6)

                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.appEmerald)
                            .frame(width: 8, height: 8)
                        Text(auth.currentUser ?? "Budget")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task { await store.refreshAll() }
                    }) {
                        if store.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionSheet(defaultType: selectedTxType)
            }
            .sheet(isPresented: $showingTransfer) {
                TransferSheet()
            }
        }
    }

    // MARK: - Subviews
    private var monthSelectorBar: some View {
        HStack {
            Button(action: {
                var m = store.selectedMonth - 1
                var y = store.selectedYear
                if m < 1 { m = 12; y -= 1 }
                Task { await store.changeMonth(year: y, month: m) }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundColor(.appSapphire)
                    .font(.subheadline)

                Text(monthName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: {
                var m = store.selectedMonth + 1
                var y = store.selectedYear
                if m > 12 { m = 1; y += 1 }
                Task { await store.changeMonth(year: y, month: m) }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .liquidGlass(cornerRadius: 14)
    }

    private var quickActionGrid: some View {
        HStack(spacing: 12) {
            // Uitgave toevoegen
            Button(action: {
                selectedTxType = .variableExpense
                showingAddTransaction = true
            }) {
                quickActionButton(title: "Uitgave", icon: "minus.circle.fill", color: .appRose)
            }

            // Inkomst toevoegen
            Button(action: {
                selectedTxType = .income
                showingAddTransaction = true
            }) {
                quickActionButton(title: "Inkomst", icon: "plus.circle.fill", color: .appEmerald)
            }

            // Overboeken
            Button(action: {
                showingTransfer = true
            }) {
                quickActionButton(title: "Overboeken", icon: "arrow.left.arrow.right.circle.fill", color: .appSapphire)
            }
        }
    }

    private func quickActionButton(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 14, strokeColor: color.opacity(0.3))
    }

    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("UITGAVEN PER CATEGORIE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.1)

                Spacer()

                NavigationLink(destination: BudgetsView()) {
                    Text("Budgetten")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.appSapphire)
                }
            }
            .padding(.horizontal, 4)

            VStack(spacing: 10) {
                ForEach(store.categoryBreakdown.prefix(4)) { item in
                    HStack(spacing: 12) {
                        CategoryIconView(icon: item.categoryIcon, colorHex: item.categoryColor, size: 36, iconSize: 16)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(item.categoryName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()

                                Text(CurrencyFormatter.format(item.totalAmount))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }

                            // Progress bar
                            if let usedPct = item.budgetUsedPercentage {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 6)

                                        Capsule()
                                            .fill(
                                                usedPct > 100 ? Color.appRose :
                                                usedPct > 80 ? Color.appAmber : Color.appEmerald
                                            )
                                            .frame(width: min(geo.size.width * CGFloat(usedPct / 100.0), geo.size.width), height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                    }
                    .padding(12)
                    .liquidGlass(cornerRadius: 14)
                }
            }
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("RECENTE TRANSACTIES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.1)

                Spacer()

                NavigationLink(destination: TransactionsView()) {
                    Text("Volledig overzicht")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.appSapphire)
                }
            }
            .padding(.horizontal, 4)

            if store.recentTransactions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                        Text("Nog geen transacties voor deze maand")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(24)
                    Spacer()
                }
                .liquidGlass(cornerRadius: 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.recentTransactions.prefix(5)) { tx in
                        TransactionRowView(transaction: tx)
                    }
                }
            }
        }
    }
}
