import SwiftUI

public struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared
    public let transaction: Transaction
    @State private var showingDeleteConfirm = false
    @State private var isDeleting = false

    private var isIncome: Bool {
        transaction.type == .income
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Amount & Icon
                        VStack(spacing: 12) {
                            CategoryIconView(
                                icon: transaction.category?.icon,
                                colorHex: transaction.category?.color,
                                size: 64,
                                iconSize: 28
                            )

                            Text(CurrencyFormatter.formatSigned(transaction.amount, isIncome: isIncome))
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(isIncome ? .appEmerald : .white)

                            Text(transaction.type.displayName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)

                        // Details List
                        VStack(spacing: 14) {
                            detailRow(title: "Begunstigde / Omschrijving", value: transaction.payee.isEmpty ? transaction.description : transaction.payee)
                            detailRow(title: "Datum", value: transaction.date)
                            detailRow(title: "Categorie", value: transaction.category?.name ?? "Geen")
                            detailRow(title: "Rekening", value: transaction.account?.name ?? "Geen")
                            if !transaction.notes.isEmpty {
                                detailRow(title: "Notities", value: transaction.notes)
                            }
                            if !transaction.tags.isEmpty {
                                detailRow(title: "Labels", value: transaction.tags)
                            }
                        }
                        .padding(18)
                        .liquidGlass(cornerRadius: 20)

                        // Delete Button
                        Button(action: {
                            showingDeleteConfirm = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Transactie Verwijderen")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.appRose)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .liquidGlass(cornerRadius: 16, strokeColor: Color.appRose.opacity(0.4))
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Transactie Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Klaar") {
                        dismiss()
                    }
                    .foregroundColor(.appEmerald)
                }
            }
            .alert("Transactie verwijderen?", isPresented: $showingDeleteConfirm) {
                Button("Annuleren", role: .cancel) {}
                Button("Verwijder", role: .destructive) {
                    Task {
                        isDeleting = true
                        await store.deleteTransaction(id: transaction.id)
                        dismiss()
                    }
                }
            } message: {
                Text("Weet je zeker dat je deze transactie van € \(String(format: "%.2f", transaction.amount)) wilt verwijderen? Dit wordt direct gesynchroniseerd met budget.ivoozz.nl.")
            }
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}
