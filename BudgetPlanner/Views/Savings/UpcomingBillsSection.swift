import SwiftUI

public struct UpcomingBillsSection: View {
    public let bills: [UpcomingBill]
    @ObservedObject var store = BudgetStore.shared

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("VASTE LASTEN KALENDER")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.1)

                Spacer()

                Text("Komende 30 dagen")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)

            if bills.isEmpty {
                HStack {
                    Spacer()
                    Text("Geen geplande vaste lasten")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(20)
                    Spacer()
                }
                .liquidGlass(cornerRadius: 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(bills) { bill in
                        HStack(spacing: 12) {
                            CategoryIconView(
                                icon: bill.category?.icon,
                                colorHex: bill.category?.color,
                                size: 38,
                                iconSize: 18
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(bill.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text("Vervalt: \(bill.dueDate) (\(bill.daysUntil)d)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 3) {
                                Text(CurrencyFormatter.format(bill.amount, privacy: store.privacyMode))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.appRose)

                                Button(action: {
                                    Task { await store.generateRecurringBill(ruleId: bill.ruleId) }
                                }) {
                                    Text("Boek nu")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.appSapphire)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.appSapphire.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(12)
                        .liquidGlass(cornerRadius: 14)
                    }
                }
            }
        }
    }
}
