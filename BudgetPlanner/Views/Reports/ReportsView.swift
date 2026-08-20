import SwiftUI

public struct ReportsView: View {
    @ObservedObject var store = BudgetStore.shared

    public init() {}

    private var yearTotals: (income: Double, fixed: Double, variable: Double, oneTime: Double, totalExpenses: Double, net: Double) {
        store.cashflowTrends.reduce((0, 0, 0, 0, 0, 0)) { acc, p in
            (
                acc.0 + p.income,
                acc.1 + p.fixedExpenses,
                acc.2 + p.variableExpenses,
                acc.3 + p.oneTimeExpenses,
                acc.4 + p.totalExpenses,
                acc.5 + p.netSavings
            )
        }
    }

    private func monthName(_ monthNumber: Int) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "nl_NL")
        let symbols = df.monthSymbols ?? []
        let index = monthNumber - 1
        if index >= 0 && index < symbols.count {
            return symbols[index].capitalized
        }
        return "M\(monthNumber)"
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        // Month & Privacy Bar
                        MonthNavigationBar()

                        // Annual KPI Summary Cards
                        annualKPIHeaderView

                        // 12-Month Matrix List / Table
                        monthlyMatrixSectionView

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await store.refreshAll()
                }
            }
            .navigationTitle("Jaaranalyse \(String(store.selectedYear))")
        }
    }

    // MARK: - Subviews
    private var annualKPIHeaderView: some View {
        VStack(spacing: 12) {
            // Net Year Result
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("JAARTOTAAL NETTO RESULTAAT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1.1)

                    Text(CurrencyFormatter.format(yearTotals.net, privacy: store.privacyMode))
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(yearTotals.net >= 0 ? .appEmerald : .appRose)
                }

                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 26))
                    .foregroundColor(.appEmerald)
            }
            .padding(16)
            .liquidGlass(cornerRadius: 18, strokeColor: Color.appEmerald.opacity(0.3))

            // 4 Grid KPI Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                kpiCard(title: "JAAR INKOMSTEN", amount: yearTotals.income, color: .appEmerald, icon: "arrow.down.left")
                kpiCard(title: "TOTALE UITGAVEN", amount: yearTotals.totalExpenses, color: .appRose, icon: "arrow.up.right")
                kpiCard(title: "VASTE LASTEN", amount: yearTotals.fixed, color: .appSapphire, icon: "repeat")
                kpiCard(title: "VARIABEL / OVERIG", amount: yearTotals.variable + yearTotals.oneTime, color: .appAmber, icon: "cart")
            }
        }
    }

    private func kpiCard(title: String, amount: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(color)
                    .tracking(0.8)
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
            }
            Text(CurrencyFormatter.format(amount, privacy: store.privacyMode))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(12)
        .liquidGlass(cornerRadius: 14, strokeColor: color.opacity(0.2))
    }

    private var monthlyMatrixSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MAANDOVERZICHT MATRIX (\(String(store.selectedYear)))")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.1)

            if store.cashflowTrends.isEmpty {
                VStack(spacing: 8) {
                    Text("Geen gegevens beschikbaar voor dit jaar.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .liquidGlass(cornerRadius: 18)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.cashflowTrends, id: \.month) { point in
                        monthMatrixRow(point)
                    }
                }
            }
        }
    }

    private func monthMatrixRow(_ p: CashFlowPoint) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(monthName(p.month))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(p.netSavings >= 0 ? "+" : "")\(CurrencyFormatter.format(p.netSavings, privacy: store.privacyMode))")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(p.netSavings >= 0 ? .appEmerald : .appRose)
            }

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle().fill(Color.appEmerald).frame(width: 5, height: 5)
                    Text("Ink:")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(CurrencyFormatter.formatCompact(p.income, privacy: store.privacyMode))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }

                HStack(spacing: 4) {
                    Circle().fill(Color.appSapphire).frame(width: 5, height: 5)
                    Text("Vast:")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(CurrencyFormatter.formatCompact(p.fixedExpenses, privacy: store.privacyMode))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }

                HStack(spacing: 4) {
                    Circle().fill(Color.appAmber).frame(width: 5, height: 5)
                    Text("Var:")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Text(CurrencyFormatter.formatCompact(p.variableExpenses, privacy: store.privacyMode))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()
            }
        }
        .padding(12)
        .liquidGlass(cornerRadius: 14)
    }
}
