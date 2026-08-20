import SwiftUI

public struct AddSavingsGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    @State private var name = ""
    @State private var targetAmountString = ""
    @State private var initialAmountString = ""
    @State private var selectedColor = "#10B981"
    @State private var selectedDate = Date().addingTimeInterval(86400 * 90)
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    private let colors = ["#10B981", "#3B82F6", "#8B5CF6", "#F59E0B", "#EC4899", "#06B6D4"]

    private var parsedTarget: Double {
        Double(targetAmountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }

    private var parsedInitial: Double {
        Double(initialAmountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#090D16").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Goal Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NAAM SPAARDOEL")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            TextField("Bijv. Vakantie Italië, Noodfonds, Nieuwe Laptop", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }

                        // Target Amount
                        VStack(alignment: .leading, spacing: 6) {
                            Text("DOELBEDRAG")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack {
                                Text("€").foregroundColor(.gray)
                                TextField("1000,00", text: $targetAmountString)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        // Initial Amount
                        VStack(alignment: .leading, spacing: 6) {
                            Text("HUIDIG SPAARSALDO (OPTIONEEL)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack {
                                Text("€").foregroundColor(.gray)
                                TextField("0,00", text: $initialAmountString)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        // Color selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KLEUR")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack(spacing: 14) {
                                ForEach(colors, id: \.self) { hex in
                                    let isSel = (selectedColor == hex)
                                    Button(action: {
                                        selectedColor = hex
                                        HapticManager.selection()
                                    }) {
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle().stroke(Color.white, lineWidth: isSel ? 3 : 0)
                                            )
                                    }
                                }
                            }
                        }

                        if let err = errorMessage {
                            Text(err).font(.caption).foregroundColor(.appRose)
                        }

                        Button(action: handleSave) {
                            HStack {
                                if isSubmitting {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Spaardoel Aanmaken")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appEmerald)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .disabled(isSubmitting || name.isEmpty || parsedTarget <= 0)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Nieuw Spaardoel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuleren") { dismiss() }.foregroundColor(.gray)
                }
            }
        }
    }

    private func handleSave() {
        guard !name.isEmpty, parsedTarget > 0 else { return }
        isSubmitting = true
        errorMessage = nil
        HapticManager.impact(.medium)

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: selectedDate)

        Task {
            do {
                _ = try await APIService.shared.createSavingsGoal(
                    name: name,
                    targetAmount: parsedTarget,
                    currentAmount: parsedInitial,
                    targetDate: dateStr,
                    color: selectedColor
                )
                await store.refreshAll()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
