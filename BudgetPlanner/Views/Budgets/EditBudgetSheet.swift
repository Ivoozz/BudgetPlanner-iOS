import SwiftUI

public struct EditBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    public let categoryItem: CategoryBreakdownItem
    @State private var amountString: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    private var parsedAmount: Double {
        let clean = amountString.replacingOccurrences(of: ",", with: ".")
        return Double(clean) ?? 0.0
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                VStack(spacing: 24) {
                    // Header Category Info
                    VStack(spacing: 10) {
                        CategoryIconView(icon: categoryItem.categoryIcon, colorHex: categoryItem.categoryColor, size: 60, iconSize: 26)
                        Text(categoryItem.categoryName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Stel een maandelijks bestedingslimiet in")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)

                    // Amount input
                    VStack(spacing: 6) {
                        Text("MAANDLIMIET")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("€")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            TextField("0,00", text: $amountString)
                                .font(.system(size: 38, weight: .heavy, design: .rounded))
                                .keyboardType(.decimalPad)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(20)
                    .liquidGlass(cornerRadius: 20)

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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuleren") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                if let currentBudget = categoryItem.budgetAmount {
                    amountString = String(format: "%.2f", currentBudget)
                }
            }
        }
    }

    private func handleSave() {
        guard let catId = categoryItem.categoryId else { return }
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
