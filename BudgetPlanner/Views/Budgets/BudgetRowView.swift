import SwiftUI

public struct BudgetRowView: View {
    public let item: CategoryBreakdownItem
    public var onEdit: (() -> Void)? = nil

    private var percentage: Double {
        item.budgetUsedPercentage ?? 0.0
    }

    private var barColor: Color {
        if percentage > 100 { return .appRose }
        if percentage > 85 { return .appAmber }
        return .appEmerald
    }

    public var body: some View {
        Button(action: {
            onEdit?()
            HapticManager.selection()
        }) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    CategoryIconView(icon: item.categoryIcon, colorHex: item.categoryColor, size: 42, iconSize: 20)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.categoryName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 4) {
                            Text("Besteed: \(CurrencyFormatter.format(item.totalAmount))")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)

                            if let b = item.budgetAmount {
                                Text("van \(CurrencyFormatter.format(b))")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        if let pct = item.budgetUsedPercentage {
                            Text("\(String(format: "%.0f", pct))%")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(barColor)
                        } else {
                            Text("Geen limiet")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                        }

                        if let rem = item.remainingBudget {
                            Text(rem >= 0 ? "Nog \(CurrencyFormatter.format(rem))" : "+\(CurrencyFormatter.format(abs(rem))) over!")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(rem >= 0 ? .gray : .appRose)
                        }
                    }
                }

                // Progress Bar
                if let _ = item.budgetAmount {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 7)

                            Capsule()
                                .fill(barColor)
                                .frame(width: min(geo.size.width * CGFloat(percentage / 100.0), geo.size.width), height: 7)
                        }
                    }
                    .frame(height: 7)
                }
            }
            .padding(14)
            .liquidGlass(cornerRadius: 16, strokeColor: item.budgetAmount != nil ? barColor.opacity(0.2) : Color.white.opacity(0.1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
