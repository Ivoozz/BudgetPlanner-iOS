import SwiftUI

public struct TransferSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    @State private var fromAccountId: Int? = nil
    @State private var toAccountId: Int? = nil
    @State private var amountString: String = ""
    @State private var description: String = "Interne overboeking"
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    private var parsedAmount: Double {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return Double(clean) ?? 0.0
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#090D16").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        // Amount input
                        VStack(spacing: 6) {
                            Text("OVER TE BOEKEN BEDRAG")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("€")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                TextField("0,00", text: $amountString)
                                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(20)
                        .liquidGlass(cornerRadius: 20)

                        // From Account
                        VStack(alignment: .leading, spacing: 8) {
                            Text("VANAF REKENING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            Picker("Vanaf", selection: $fromAccountId) {
                                ForEach(store.accounts) { acc in
                                    Text("\(acc.name) (\(CurrencyFormatter.format(acc.balance)))").tag(Optional(acc.id))
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        // Arrow Down Icon
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.appSapphire)

                        // To Account
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NAAR REKENING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            Picker("Naar", selection: $toAccountId) {
                                ForEach(store.accounts) { acc in
                                    Text("\(acc.name) (\(CurrencyFormatter.format(acc.balance)))").tag(Optional(acc.id))
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        if let err = errorMessage {
                            Text(err).font(.caption).foregroundColor(.appRose)
                        }

                        Button(action: handleTransfer) {
                            HStack {
                                if isSubmitting {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Overboeking Uitvoeren")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appSapphire)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .disabled(isSubmitting || parsedAmount <= 0 || fromAccountId == toAccountId)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Overboeken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuleren") { dismiss() }.foregroundColor(.gray)
                }
            }
            .onAppear {
                if store.accounts.count >= 2 {
                    fromAccountId = store.accounts[0].id
                    toAccountId = store.accounts[1].id
                }
            }
        }
    }

    private func handleTransfer() {
        guard parsedAmount > 0, let fromId = fromAccountId, let toId = toAccountId, fromId != toId else { return }

        isSubmitting = true
        errorMessage = nil
        HapticManager.impact(.medium)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: Date())

        Task {
            do {
                _ = try await store.addTransaction(
                    date: dateStr,
                    amount: parsedAmount,
                    type: .transfer,
                    categoryId: nil,
                    accountId: fromId,
                    destinationAccountId: toId,
                    payee: "Overboeking",
                    description: description
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
