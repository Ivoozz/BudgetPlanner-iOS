import SwiftUI

public struct AddAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    @State private var name = ""
    @State private var selectedType: AccountType = .checking
    @State private var initialBalanceString = ""
    @State private var selectedColor = "#3B82F6"
    @State private var selectedIcon = "creditcard.fill"
    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    private let colors = ["#3B82F6", "#10B981", "#8B5CF6", "#F59E0B", "#EC4899", "#64748B"]

    private var parsedInitial: Double {
        Double(initialAmountClean.replacingOccurrences(of: ",", with: ".")) ?? 0.0
    }

    private var initialAmountClean: String {
        initialBalanceString.isEmpty ? "0.0" : initialBalanceString
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#090D16").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("REKENINGNAAM")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            TextField("Bijv. ING Betaalpas, Rabo Spaar", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }

                        // Type
                        VStack(alignment: .leading, spacing: 6) {
                            Text("TYPE REKENING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            Picker("Type", selection: $selectedType) {
                                ForEach(AccountType.allCases) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        // Initial Balance
                        VStack(alignment: .leading, spacing: 6) {
                            Text("BEGINSALDO (OPTIONEEL)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack {
                                Text("€").foregroundColor(.gray)
                                TextField("0,00", text: $initialBalanceString)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        // Color
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
                                    Text("Rekening Toevoegen")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appSapphire)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .disabled(isSubmitting || name.isEmpty)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Nieuwe Rekening")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuleren") { dismiss() }.foregroundColor(.gray)
                }
            }
        }
    }

    private func handleSave() {
        guard !name.isEmpty else { return }
        isSubmitting = true
        errorMessage = nil
        HapticManager.impact(.medium)

        Task {
            do {
                _ = try await APIService.shared.createAccount(
                    name: name,
                    type: selectedType.rawValue,
                    balance: parsedInitial,
                    icon: selectedType.defaultIcon,
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
