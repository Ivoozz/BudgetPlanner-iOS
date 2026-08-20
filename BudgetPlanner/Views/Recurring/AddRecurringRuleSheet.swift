import SwiftUI

public struct AddRecurringRuleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    public var initialType: String
    public var editingRule: RecurringRule?

    @State private var name: String = ""
    @State private var amountString: String = ""
    @State private var type: String = "fixed_expense"
    @State private var frequency: String = "monthly"
    @State private var dayOfMonth: Int = 1
    @State private var selectedCategoryId: Int? = nil
    @State private var selectedAccountId: Int? = nil
    @State private var payee: String = ""
    @State private var startDate: Date = Date()
    @State private var notes: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil

    public init(initialType: String = "fixed_expense", editingRule: RecurringRule? = nil) {
        self.initialType = initialType
        self.editingRule = editingRule
    }

    private let frequencies = [
        ("monthly", "Maandelijks"),
        ("weekly", "Wekelijks"),
        ("quarterly", "Kwartaal"),
        ("semi_annually", "Halfjaarlijks"),
        ("annually", "Jaarlijks")
    ]

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0B101E").ignoresSafeArea()

                Form {
                    Section("BASIS GEGEVENS") {
                        TextField("Omschrijving (bijv. Huur / Salaris)", text: $name)
                            .foregroundColor(.white)

                        HStack {
                            Text("€")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appEmerald)
                            TextField("0.00", text: $amountString)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Picker("Type Post", selection: $type) {
                            Text("Vaste Last").tag("fixed_expense")
                            Text("Vast Inkomen").tag("income")
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    Section("FREQUENTIE & PLANNING") {
                        Picker("Frequentie", selection: $frequency) {
                            ForEach(frequencies, id: \.0) { item in
                                Text(item.1).tag(item.0)
                            }
                        }

                        Stepper("Dag van de maand: \(dayOfMonth)", value: $dayOfMonth, in: 1...31)

                        DatePicker("Startdatum", selection: $startDate, displayedComponents: .date)
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    Section("CATEGORIE & REKENING") {
                        Picker("Categorie", selection: $selectedCategoryId) {
                            Text("Geen / Algemeen").tag(nil as Int?)
                            ForEach(store.categories) { cat in
                                Text(cat.name).tag(cat.id as Int?)
                            }
                        }

                        Picker("Rekening", selection: $selectedAccountId) {
                            Text("Geen specifieke rekening").tag(nil as Int?)
                            ForEach(store.accounts) { acc in
                                Text(acc.name).tag(acc.id as Int?)
                            }
                        }

                        TextField("Begunstigde / Ontvanger", text: $payee)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    Section("NOTITIES") {
                        TextField("Optionele notities of contractnummer", text: $notes)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    if let err = errorMessage {
                        Section {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.appRose)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(editingRule != nil ? "Post Bewerken" : "Nieuwe Vaste Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleren") { dismiss() }
                        .foregroundColor(.gray)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(editingRule != nil ? "Bijwerken" : "Toevoegen") {
                        save()
                    }
                    .font(.headline)
                    .foregroundColor(.appEmerald)
                    .disabled(isSaving || name.isEmpty || (Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0)
                }
            }
            .onAppear {
                if let rule = editingRule {
                    name = rule.name
                    amountString = String(format: "%.2f", rule.amount)
                    type = rule.type
                    frequency = rule.frequency
                    dayOfMonth = rule.dayOfMonth
                    selectedCategoryId = rule.categoryId
                    selectedAccountId = rule.accountId
                    payee = rule.payee
                    notes = rule.notes
                } else {
                    type = initialType
                    if let firstCat = store.categories.first {
                        selectedCategoryId = firstCat.id
                    }
                    if let firstAcc = store.accounts.first {
                        selectedAccountId = firstAcc.id
                    }
                }
            }
        }
    }

    private func save() {
        guard let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")), amount > 0 else {
            errorMessage = "Voer een geldig bedrag in."
            return
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: startDate)

        isSaving = true
        errorMessage = nil

        Task {
            do {
                if let rule = editingRule {
                    let payload: [String: Any] = [
                        "name": name,
                        "amount": amount,
                        "type": type,
                        "frequency": frequency,
                        "day_of_month": dayOfMonth,
                        "category_id": selectedCategoryId as Any,
                        "account_id": selectedAccountId as Any,
                        "payee": payee,
                        "notes": notes,
                        "is_active": true
                    ]
                    try await store.updateRecurringRule(id: rule.id, payload: payload)
                } else {
                    try await store.addRecurringRule(
                        name: name,
                        amount: amount,
                        type: type,
                        frequency: frequency,
                        dayOfMonth: dayOfMonth,
                        categoryId: selectedCategoryId,
                        accountId: selectedAccountId,
                        payee: payee,
                        startDate: dateStr,
                        notes: notes
                    )
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}
