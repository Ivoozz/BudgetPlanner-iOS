import SwiftUI

public struct HeroBalanceCard: View {
    public let summary: MonthSummary
    @ObservedObject var store = BudgetStore.shared

    public init(summary: MonthSummary) {
        self.summary = summary
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NETTO RESULTAAT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1.2)

                    Text(CurrencyFormatter.format(summary.netSavings, privacy: store.privacyMode))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(summary.netSavings >= 0 ? .appEmerald : .appRose)
                }

                Spacer()

                // Savings Rate Badge
                VStack(spacing: 2) {
                    Text(store.privacyMode ? "••%" : "\(String(format: "%.1f", summary.savingsRate))%")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.appEmerald)
                    Text("Spaarquote")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.appEmerald.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appEmerald.opacity(0.3), lineWidth: 1)
                )
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // 3-Column Breakdown: Inkomsten, Vaste Lasten, Variabel/Overig
            HStack(spacing: 8) {
                // Inkomsten
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.appEmerald).frame(width: 6, height: 6)
                        Text("Inkomsten")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text(CurrencyFormatter.formatCompact(summary.totalIncome, privacy: store.privacyMode))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Vaste Lasten
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.appSapphire).frame(width: 6, height: 6)
                        Text("Vast")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text(CurrencyFormatter.formatCompact(summary.totalFixedExpenses, privacy: store.privacyMode))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Variabel + Eenmalig
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.appAmber).frame(width: 6, height: 6)
                        Text("Variabel")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text(CurrencyFormatter.formatCompact(summary.totalVariableExpenses + summary.totalOneTimeExpenses, privacy: store.privacyMode))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22, strokeColor: Color.appEmerald.opacity(0.3))
    }
}
