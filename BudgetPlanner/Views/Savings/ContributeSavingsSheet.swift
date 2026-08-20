import SwiftUI

public struct ContributeSavingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    public let goal: SavingsGoal
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
                    VStack(spacing: 8) {
                        Text(goal.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("Nog \(CurrencyFormatter.format(goal.remainingAmount)) te gaan")
                            .font(.subheadline)
                            .foregroundColor(.appEmerald)
                    }
                    .padding(.top, 20)

                    // Amount input
                    VStack(spacing: 6) {
                        Text("BIJ TE STORTEN BEDRAG")
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

                    // Quick chip suggestions (€25, €50, €100, €250)
                    HStack(spacing: 10) {
                        ForEach([25.0, 50.0, 100.0, 250.0], id: \.self) { chip in
                            Button(action: {
                                amountString = String(format: "%.0f", chip)
                                HapticManager.selection()
                            }) {
                                Text("+€\(Int(chip))")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if let err = errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.appRose)
                    }

                    Button(action: handleSave) {
                        HStack {
                            if isSubmitting {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Inleggen")
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
            .navigationTitle("Inleg Spaardoel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuleren") { dismiss() }
                        .foregroundColor(.gray)
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
                try await store.contributeToSavingsGoal(id: goal.id, amount: parsedAmount)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
