import SwiftUI

public struct EditBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    public var item: CategoryBreakdownItem?
    @State private var selectedCategoryId: Int? = nil
    @State private var amountString: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil

    public init(item: CategoryBreakdownItem? = nil) {
        self.item = item
    }

    private var parsedAmount: Double {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return Double(clean) ?? 0.0
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0B101E").ignoresSafeArea()

                VStack(spacing: 20) {
                    // Category Picker or Info
                    if let categoryItem = item {
                        VStack(spacing: 8) {
                            CategoryIconView(icon: categoryItem.categoryIcon, colorHex: categoryItem.categoryColor, size: 52, iconSize: 24)
                            Text(categoryItem.categoryName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 16)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CATEGORIE KIEZEN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            Picker("Categorie", selection: $selectedCategoryId) {
                                ForEach(store.categories) { cat in
                                    Text(cat.name).tag(cat.id as Int?)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                        }
                        .padding(.top, 16)
                    }

                    // Amount input
                    VStack(spacing: 6) {
                        Text("MAANDELIJKS BUDGET")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("€")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            TextField("0,00", text: $amountString)
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .keyboardType(.decimalPad)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(18)
                    .liquidGlass(cornerRadius: 18)

                    if let err = errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.appRose)
                    }

                    // Save Button
                    Button(action: handleSave) {
                        HStack {
                            if isSubmitting {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Budget Opslaan")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.appEmerald, Color(hex: "#059669")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(isSubmitting || parsedAmount <= 0)
                    .opacity(parsedAmount > 0 ? 1.0 : 0.6)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Budget Instellen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleren") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                if let i = item {
                    selectedCategoryId = i.categoryId
                    if let currentBudget = i.budgetAmount {
                        amountString = String(format: "%.2f", currentBudget)
                    }
                } else {
                    selectedCategoryId = store.categories.first?.id
                }
            }
        }
    }

    private func handleSave() {
        guard let catId = selectedCategoryId else { return }
        isSubmitting = true
        errorMessage = nil
        HapticManager.impact(.medium)

        Task {
            do {
                try await store.upsertBudget(categoryId: catId, amount: parsedAmount)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
