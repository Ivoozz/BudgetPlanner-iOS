import SwiftUI

public struct TransactionRowView: View {
    public let transaction: Transaction
    @ObservedObject var store = BudgetStore.shared
    @State private var showingDetail: Bool = false

    public init(transaction: Transaction) {
        self.transaction = transaction
    }

    private var isIncome: Bool {
        transaction.type == .income
    }

    private var isTransfer: Bool {
        transaction.type == .transfer
    }

    private var formattedAmount: String {
        if isTransfer {
            return CurrencyFormatter.format(transaction.amount, privacy: store.privacyMode)
        }
        return CurrencyFormatter.formatSigned(transaction.amount, isIncome: isIncome, privacy: store.privacyMode)
    }

    private var amountColor: Color {
        if isTransfer { return .appSapphire }
        return isIncome ? .appEmerald : .white
    }

    private var titleText: String {
        if !transaction.payee.isEmpty {
            return transaction.payee
        }
        if !transaction.description.isEmpty {
            return transaction.description
        }
        return transaction.category?.name ?? transaction.type.displayName
    }

    public var body: some View {
        Button(action: {
            showingDetail = true
            HapticManager.selection()
        }) {
            HStack(spacing: 12) {
                CategoryIconView(
                    icon: transaction.category?.icon ?? (isTransfer ? "arrow.left.arrow.right" : "tag.fill"),
                    colorHex: transaction.category?.color ?? (isTransfer ? "#3B82F6" : "#64748B"),
                    size: 38,
                    iconSize: 17
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(titleText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(transaction.date)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)

                        if let acc = transaction.account {
                            Text("•")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text(acc.name)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(formattedAmount)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(amountColor)

                    if let cat = transaction.category {
                        Text(cat.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
            .padding(12)
            .liquidGlass(cornerRadius: 16)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            TransactionDetailView(transaction: transaction)
        }
    }
}
