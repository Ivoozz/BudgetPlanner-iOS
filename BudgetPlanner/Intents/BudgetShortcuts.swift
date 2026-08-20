import AppIntents
import SwiftUI

public struct AddQuickExpenseIntent: AppIntent {
    public static var title: LocalizedStringResource = "Snel Uitgave Toevoegen"
    public static var description = IntentDescription("Registreer snel een uitgave in BudgetPlanner")

    @Parameter(title: "Bedrag in Euro", default: 0.0)
    var amount: Double

    @Parameter(title: "Omschrijving / Winkel", default: "")
    var payee: String

    public init() {}

    public func perform() async throws -> some ProvidesDialog {
        guard amount > 0 else {
            return .result(dialog: "Voer een geldig bedrag in.")
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: Date())

        do {
            _ = try await APIService.shared.createTransaction(
                date: dateStr,
                amount: amount,
                type: TransactionType.variableExpense.rawValue,
                categoryId: nil,
                accountId: nil,
                payee: payee,
                description: payee
            )
            return .result(dialog: "Uitgave van € \(String(format: "%.2f", amount)) voor \(payee) succesvol opgeslagen in BudgetPlanner!")
        } catch {
            return .result(dialog: "Fout bij opslaan: \(error.localizedDescription)")
        }
    }
}

public struct BudgetShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddQuickExpenseIntent(),
            phrases: [
                "Boek een uitgave in \(.applicationName)",
                "Registreer uitgave met \(.applicationName)"
            ],
            shortTitle: "Snel Uitgave Boeken",
            systemImageName: "eurosign.circle.fill"
        )
    }
}
