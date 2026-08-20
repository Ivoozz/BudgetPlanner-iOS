import SwiftUI

public struct RecurringView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var filterSelection: String = "all" // "all", "expense", "income"
    @State private var showingAddSheet: Bool = false
    @State private var selectedInitialType: String = "fixed_expense"
    @State private var editingRule: RecurringRule? = nil
    @State private var statusAlertMessage: String? = nil
    @State private var showingStatusAlert: Bool = false

    public init() {}

    private var filteredRules: [RecurringRule] {
        switch filterSelection {
        case "income":
            return store.incomeRecurringRules
        case "expense":
            return store.expenseRecurringRules
        default:
            return store.recurringRules
        }
    }

    private var monthName: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "nl_NL")
        let symbols = df.monthSymbols ?? []
        let index = store.selectedMonth - 1
        if index >= 0 && index < symbols.count {
            return symbols[index].capitalized
        }
        return "\(store.selectedMonth)"
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        // Month & Privacy Bar
                        MonthNavigationBar()

                        // 3 Summary Cards
                        summaryKPIView

                        // Filter Pills & Add Actions
                        headerAndFiltersView

                        // Rules List
                        if filteredRules.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredRules) { rule in
                                    recurringRuleCard(rule)
                                }
                            }
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
            .navigationTitle("Vaste Posten")
            .sheet(isPresented: $showingAddSheet) {
                AddRecurringRuleSheet(initialType: selectedInitialType, editingRule: editingRule)
            }
            .alert("Status", isPresented: $showingStatusAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(statusAlertMessage ?? "")
            }
        }
    }

    // MARK: - Subviews
    private var summaryKPIView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                // Vast Inkomen
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("VAST INKOMEN")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.appEmerald)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.appEmerald)
                    }
                    Text("+\(CurrencyFormatter.format(store.totalMonthlyIncome, privacy: store.privacyMode))")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.appEmerald)
                    Text("Salaris & vaste inkomsten")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .liquidGlass(cornerRadius: 16, strokeColor: Color.appEmerald.opacity(0.3))

                // Vaste Lasten
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("VASTE LASTEN")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.appRose)
                        Spacer()
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.appRose)
                    }
                    Text("-\(CurrencyFormatter.format(store.totalMonthlyExpense, privacy: store.privacyMode))")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.appRose)
                    Text("Wonen, energie, abbo's")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .liquidGlass(cornerRadius: 16, strokeColor: Color.appRose.opacity(0.3))
            }

            // Vrije Ruimte na Vaste Lasten
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("VRIJE RUIMTE NA VASTE LASTEN")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.appSapphire)
                    Text(CurrencyFormatter.format(store.netFixedRemaining, privacy: store.privacyMode))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(store.netFixedRemaining >= 0 ? .white : .appRose)
                }

                Spacer()

                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 24))
                    .foregroundColor(.appSapphire)
            }
            .padding(14)
            .liquidGlass(cornerRadius: 16, strokeColor: Color.appSapphire.opacity(0.3))
        }
    }

    private var headerAndFiltersView: some View {
        VStack(spacing: 12) {
            HStack {
                // Action Buttons
                Button(action: {
                    editingRule = nil
                    selectedInitialType = "income"
                    showingAddSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("+ Inkomen")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appEmerald)
                    .cornerRadius(12)
                }

                Button(action: {
                    editingRule = nil
                    selectedInitialType = "fixed_expense"
                    showingAddSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("+ Vaste Last")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appSapphire)
                    .cornerRadius(12)
                }

                Spacer()
            }

            // Filter Pills
            HStack(spacing: 8) {
                filterPill(title: "Alles (\(store.recurringRules.count))", id: "all")
                filterPill(title: "Vaste Lasten (\(store.expenseRecurringRules.count))", id: "expense")
                filterPill(title: "Inkomen (\(store.incomeRecurringRules.count))", id: "income")
                Spacer()
            }
        }
    }

    private func filterPill(title: String, id: String) -> some View {
        let isSelected = filterSelection == id
        return Button(action: {
            HapticManager.selection()
            filterSelection = id
        }) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
                        .overlay(
                            Capsule().strokeBorder(isSelected ? Color.appEmerald.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                )
        }
    }

    private func recurringRuleCard(_ rule: RecurringRule) -> some View {
        let isIncome = rule.type == "income"
        let cat = store.categories.first { $0.id == rule.categoryId }

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(isIncome ? Color.appEmerald.opacity(0.2) : (cat != nil ? Color(hex: cat!.color).opacity(0.2) : Color.appSapphire.opacity(0.2)))
                        .frame(width: 44, height: 44)

                    Image(systemName: isIncome ? "arrow.up.right" : (cat?.icon ?? "repeat"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isIncome ? .appEmerald : (cat != nil ? Color(hex: cat!.color) : .appSapphire))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(rule.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)

                        Text(isIncome ? "INKOMEN" : "VAST")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(isIncome ? .appEmerald : .appRose)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(isIncome ? Color.appEmerald.opacity(0.15) : Color.appRose.opacity(0.15))
                            .cornerRadius(6)
                    }

                    Text("\(cat?.name ?? "Algemeen") • Elke \(rule.dayOfMonth)e vd maand • \(rule.frequencyLabel)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Amount
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyFormatter.formatSigned(rule.amount, isIncome: isIncome, privacy: store.privacyMode))
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(isIncome ? .appEmerald : .white)

                    if rule.frequency != "monthly" {
                        Text("~\(CurrencyFormatter.format(rule.monthlyEquivalent, privacy: store.privacyMode))/mnd")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
            }

            Divider().background(Color.white.opacity(0.08))

            // Action Buttons
            HStack {
                Button(action: {
                    Task {
                        HapticManager.impact(.medium)
                        do {
                            let res = try await APIService.shared.generateRecurringTransaction(
                                ruleId: rule.id,
                                year: store.selectedYear,
                                month: store.selectedMonth
                            )
                            if let status = res["status"] as? String, status == "already_exists" {
                                statusAlertMessage = res["message"] as? String ?? "Reeds geboekt voor deze maand."
                            } else {
                                statusAlertMessage = "Succesvol geboekt voor \(monthName)!"
                                await store.refreshAll()
                            }
                            showingStatusAlert = true
                        } catch {
                            statusAlertMessage = error.localizedDescription
                            showingStatusAlert = true
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Boek voor \(monthName)")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.appEmerald)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.appEmerald.opacity(0.15))
                    .cornerRadius(8)
                }

                Spacer()

                Button(action: {
                    editingRule = rule
                    selectedInitialType = rule.type
                    showingAddSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.06)))
                }

                Button(action: {
                    Task {
                        HapticManager.notification(.warning)
                        await store.deleteRecurringRule(id: rule.id)
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundColor(.appRose)
                        .padding(8)
                        .background(Circle().fill(Color.appRose.opacity(0.12)))
                }
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 18)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "repeat.circle")
                .font(.system(size: 44))
                .foregroundColor(.gray.opacity(0.5))
            Text("Geen periodieke posten gevonden")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            Text("Voeg je salaris of vaste lasten zoals huur, energie of abonnementen toe.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 20)
    }
}
