import SwiftUI

public struct AddTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    public var defaultType: TransactionType = .variableExpense

    @State private var amountString: String = ""
    @State private var selectedType: TransactionType = .variableExpense
    @State private var selectedCategoryId: Int? = nil
    @State private var selectedAccountId: Int? = nil
    @State private var selectedDate: Date = Date()
    @State private var payee: String = ""
    @State private var notes: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil

    public init(defaultType: TransactionType = .variableExpense) {
        self.defaultType = defaultType
    }

    private var parsedAmount: Double {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return Double(clean) ?? 0.0
    }

    private var formattedDateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: selectedDate)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Transaction Type Segmented Control
                        Picker("Type", selection: $selectedType) {
                            Text("Variabel").tag(TransactionType.variableExpense)
                            Text("Vast").tag(TransactionType.fixedExpense)
                            Text("Inkomst").tag(TransactionType.income)
                            Text("Eenmalig").tag(TransactionType.oneTimeExpense)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 4)

                        // 2. Large Amount Input Card
                        VStack(spacing: 6) {
                            Text("BEDRAG")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("€")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(selectedType == .income ? .appEmerald : .white)

                                TextField("0,00", text: $amountString)
                                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(selectedType == .income ? .appEmerald : .white)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(20)
                        .liquidGlass(cornerRadius: 20)

                        // 3. Category Selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CATEGORIE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(store.categories.filter { cat in
                                        if selectedType == .income {
                                            return cat.type == .income
                                        } else {
                                            return cat.type != .income
                                        }
                                    }) { cat in
                                        let isSelected = (selectedCategoryId == cat.id)
                                        Button(action: {
                                            selectedCategoryId = cat.id
                                            HapticManager.selection()
                                        }) {
                                            VStack(spacing: 6) {
                                                CategoryIconView(icon: cat.icon, colorHex: cat.color, size: 44, iconSize: 20)
                                                Text(cat.name)
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(isSelected ? .white : .gray)
                                                    .lineLimit(1)
                                            }
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .fill(isSelected ? Color(hex: cat.color).opacity(0.3) : Color.clear)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .stroke(isSelected ? Color(hex: cat.color) : Color.clear, lineWidth: 1.5)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 18)

                        // 4. Account & Date Selector
                        VStack(spacing: 14) {
                            // Rekening
                            HStack {
                                Text("Betaald van / naar")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                Spacer()

                                Picker("Rekening", selection: $selectedAccountId) {
                                    ForEach(store.accounts) { acc in
                                        Text(acc.name).tag(Optional(acc.id))
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(.appSapphire)
                            }

                            Divider().background(Color.white.opacity(0.1))

                            // Datum
                            HStack {
                                Text("Datum")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)

                                Spacer()

                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .accentColor(.appEmerald)
                            }
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 18)

                        // 5. Payee & Notes
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                                TextField("Begunstigde / Omschrijving (bijv. Albert Heijn)", text: $payee)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)

                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.gray)
                                TextField("Optionele notitie...", text: $notes)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }
                        .padding(16)
                        .liquidGlass(cornerRadius: 18)

                        if let err = errorMessage {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.appRose)
                        }

                        // 6. Save Button
                        Button(action: handleSave) {
                            HStack {
                                if isSubmitting {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.bold)
                                    Text("Transactie Opslaan")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.appEmerald, Color(hex: "#059669")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.appEmerald.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isSubmitting || parsedAmount <= 0)
                        .opacity(parsedAmount > 0 ? 1.0 : 0.6)

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Nieuwe Transactie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuleren") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .onAppear {
                self.selectedType = defaultType
                if selectedAccountId == nil, let firstAcc = store.accounts.first {
                    selectedAccountId = firstAcc.id
                }
                if selectedCategoryId == nil, let firstCat = store.categories.first {
                    selectedCategoryId = firstCat.id
                }
            }
        }
    }

    private func handleSave() {
        guard parsedAmount > 0 else { return }

        isSubmitting = true
        errorMessage = nil
        HapticManager.impact(.medium)

        Task {
            do {
                try await store.addTransaction(
                    date: formattedDateString,
                    amount: parsedAmount,
                    type: selectedType,
                    categoryId: selectedCategoryId,
                    accountId: selectedAccountId,
                    payee: payee,
                    description: payee,
                    notes: notes
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
