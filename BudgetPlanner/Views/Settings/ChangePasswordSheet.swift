import SwiftUI

public struct ChangePasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var isSaving: Bool = false
    @State private var statusMessage: String? = nil
    @State private var isSuccess: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0B101E").ignoresSafeArea()

                Form {
                    Section("BEVEILIGING") {
                        SecureField("Huidig Wachtwoord", text: $oldPassword)
                            .foregroundColor(.white)

                        SecureField("Nieuw Wachtwoord (min. 4 tekens)", text: $newPassword)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    if let msg = statusMessage {
                        Section {
                            Text(msg)
                                .font(.caption)
                                .foregroundColor(isSuccess ? .appEmerald : .appRose)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Wachtwoord Wijzigen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleren") { dismiss() }
                        .foregroundColor(.gray)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Opslaan") {
                        change()
                    }
                    .font(.headline)
                    .foregroundColor(.appEmerald)
                    .disabled(isSaving || oldPassword.isEmpty || newPassword.count < 4)
                }
            }
        }
    }

    private func change() {
        isSaving = true
        statusMessage = nil

        Task {
            do {
                let msg = try await APIService.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                statusMessage = msg
                isSuccess = true
                HapticManager.notification(.success)
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                dismiss()
            } catch {
                statusMessage = error.localizedDescription
                isSuccess = false
                isSaving = false
            }
        }
    }
}
