import SwiftUI

public struct DailyBudgetCard: View {
    public let summary: MonthSummary
    @ObservedObject var store = BudgetStore.shared

    public init(summary: MonthSummary) {
        self.summary = summary
    }

    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appSapphire.opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(systemName: "gauge.with.needle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.appSapphire)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("DAGELIJKS VRIJ BUDGET")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.0)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(CurrencyFormatter.format(summary.dailyBudgetRemaining, privacy: store.privacyMode))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(summary.dailyBudgetRemaining >= 0 ? .white : .appRose)

                    Text("/ dag")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(summary.daysLeftInMonth)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("dagen resterend")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.06))
            .cornerRadius(10)
        }
        .padding(18)
        .liquidGlass(cornerRadius: 20, strokeColor: Color.appSapphire.opacity(0.3))
    }
}
