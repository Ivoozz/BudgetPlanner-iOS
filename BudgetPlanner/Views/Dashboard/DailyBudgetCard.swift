import SwiftUI

public struct DailyBudgetCard: View {
    public let dailyAmount: Double
    public let daysLeft: Int

    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appSapphire.opacity(0.18))
                    .frame(width: 46, height: 46)

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appSapphire)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("DAGELIJKS BESTEEDBAAR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.0)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(CurrencyFormatter.format(dailyAmount))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("/ dag")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(daysLeft) dagen")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.appSapphire)
                Text("te gaan")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.appSapphire.opacity(0.12))
            .clipShape(Capsule())
        }
        .padding(16)
        .liquidGlass(cornerRadius: 18, strokeColor: Color.appSapphire.opacity(0.25))
    }
}
