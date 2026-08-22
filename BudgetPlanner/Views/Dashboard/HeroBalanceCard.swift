import SwiftUI

public struct HeroBalanceCard: View {
    public let summary: MonthSummary
    @ObservedObject var store = BudgetStore.shared

    public init(summary: MonthSummary) {
        self.summary = summary
    }

    private var totalExpenses: Double {
        summary.totalFixedExpenses + summary.totalVariableExpenses + summary.totalOneTimeExpenses
    }

    private var fixedPct: Double {
        guard summary.totalIncome > 0 else { return 0 }
        return min(summary.totalFixedExpenses / summary.totalIncome, 1.0)
    }

    private var variablePct: Double {
        guard summary.totalIncome > 0 else { return 0 }
        return min(summary.totalVariableExpenses / summary.totalIncome, 1.0)
    }

    private var remainingPct: Double {
        guard summary.totalIncome > 0 else { return 0 }
        return max((summary.totalIncome - totalExpenses) / summary.totalIncome, 0.0)
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Header: Netto Resultaat & Spaarquote
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("UITGAVEN & RESULTAAT DEZE MAAND")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1.2)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(CurrencyFormatter.format(summary.netSavings, privacy: store.privacyMode))
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(summary.netSavings >= 0 ? .appEmerald : .appRose)

                        Text(summary.netSavings >= 0 ? "over" : "tekort")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(summary.netSavings >= 0 ? .appEmerald : .appRose)
                    }
                }

                Spacer()

                // Savings Rate Pill
                VStack(spacing: 2) {
                    Text(store.privacyMode ? "••%" : "\(String(format: "%.1f", summary.savingsRate))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(summary.savingsRate >= 0 ? .appEmerald : .appRose)
                    Text("Spaarquote")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(summary.savingsRate >= 0 ? Color.appEmerald.opacity(0.12) : Color.appRose.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(summary.savingsRate >= 0 ? Color.appEmerald.opacity(0.3) : Color.appRose.opacity(0.3), lineWidth: 1)
                )
            }

            // Visual Proportion Bar
            if summary.totalIncome > 0 {
                GeometryReader { geo in
                    HStack(spacing: 3) {
                        // Vaste Lasten segment (Blue)
                        if fixedPct > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appSapphire)
                                .frame(width: max(geo.size.width * CGFloat(fixedPct) - 3, 6), height: 8)
                        }

                        // Variabele Uitgaven segment (Amber)
                        if variablePct > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appAmber)
                                .frame(width: max(geo.size.width * CGFloat(variablePct) - 3, 6), height: 8)
                        }

                        // Vrij / Over segment (Emerald)
                        if remainingPct > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appEmerald)
                                .frame(width: max(geo.size.width * CGFloat(remainingPct) - 3, 6), height: 8)
                        }
                    }
                }
                .frame(height: 8)
            }

            Divider()
                .background(Color.white.opacity(0.08))

            // 4-Column Metric Breakdown
            HStack(spacing: 6) {
                // Inkomsten
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 3) {
                        Circle().fill(Color.appEmerald).frame(width: 5, height: 5)
                        Text("Inkomsten")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text(CurrencyFormatter.formatCompact(summary.totalIncome, privacy: store.privacyMode))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Vaste Lasten
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 3) {
                        Circle().fill(Color.appSapphire).frame(width: 5, height: 5)
                        Text("Vast")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text(CurrencyFormatter.formatCompact(summary.totalFixedExpenses, privacy: store.privacyMode))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Variabel
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 3) {
                        Circle().fill(Color.appAmber).frame(width: 5, height: 5)
                        Text("Variabel")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text(CurrencyFormatter.formatCompact(summary.totalVariableExpenses, privacy: store.privacyMode))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Totale Uitgaven
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 3) {
                        Circle().fill(Color.appRose).frame(width: 5, height: 5)
                        Text("Totaal Uit")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text(CurrencyFormatter.formatCompact(totalExpenses, privacy: store.privacyMode))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22, strokeColor: summary.netSavings >= 0 ? Color.appEmerald.opacity(0.35) : Color.appRose.opacity(0.35))
    }
}
