import SwiftUI

public struct HeroBalanceCard: View {
    public let summary: MonthSummary

    public var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NETTO RESULTAAT DIT MAAND")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1.2)

                    Text(CurrencyFormatter.format(summary.netSavings))
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(summary.netSavings >= 0 ? .appEmerald : .appRose)
                }

                Spacer()

                // Savings Rate Badge
                VStack(spacing: 2) {
                    Text("\(String(format: "%.1f", summary.savingsRate))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
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

            // 2-Column: Income vs Total Expenses
            HStack(spacing: 16) {
                // Inkomsten
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.appEmerald.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "arrow.down.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.appEmerald)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Inkomsten")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(CurrencyFormatter.format(summary.totalIncome))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Uitgaven
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.appRose.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.appRose)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Uitgaven")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(CurrencyFormatter.format(summary.totalExpenses))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 22, strokeColor: Color.appEmerald.opacity(0.3))
    }
}
