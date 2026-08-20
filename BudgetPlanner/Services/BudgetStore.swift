import Foundation
import SwiftUI
import Combine

@MainActor
public class BudgetStore: ObservableObject {
    public static let shared = BudgetStore()

    @Published public var accounts: [Account] = []
    @Published public var categories: [Category] = []
    @Published public var recentTransactions: [Transaction] = []
    @Published public var monthSummary: MonthSummary = .empty
    @Published public var categoryBreakdown: [CategoryBreakdownItem] = []
    @Published public var savingsGoals: [SavingsGoal] = []
    @Published public var upcomingBills: [UpcomingBill] = []
    @Published public var recurringRules: [RecurringRule] = []
    @Published public var cashflowTrends: [CashFlowPoint] = []

    @Published public var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published public var selectedMonth: Int = Calendar.current.component(.month, from: Date())

    @Published public var isLoading: Bool = false
    @Published public var isSyncing: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var lastSyncDate: Date? = nil

    private let api = APIService.shared
    private let offlineQueue = OfflineQueueManager.shared

    public init() {}

    public var totalBalance: Double {
        accounts.reduce(0.0) { $0 + $1.balance }
    }

    public var checkingAccounts: [Account] {
        accounts.filter { $0.type == .checking }
    }

    public var savingsAccounts: [Account] {
        accounts.filter { $0.type == .savings }
    }

    public func refreshAll() async {
        guard AuthManager.shared.isAuthenticated else { return }

        self.isLoading = true
        self.errorMessage = nil

        // 1. Flush any offline queued transactions
        await offlineQueue.flushQueue()

        do {
            async let accsTask = api.getAccounts()
            async let catsTask = api.getCategories()
            async let txsTask = api.getTransactions(year: selectedYear, month: selectedMonth, limit: 30)
            async let summaryTask = api.getMonthSummary(year: selectedYear, month: selectedMonth)
            async let breakdownTask = api.getCategoryBreakdown(year: selectedYear, month: selectedMonth)
            async let savingsTask = api.getSavingsGoals()
            async let billsTask = api.getUpcomingBills(days: 30)
            async let rulesTask = api.getRecurringRules()

            let (accs, cats, txs, summary, breakdown, savings, bills, rules) = try await (
                accsTask, catsTask, txsTask, summaryTask, breakdownTask, savingsTask, billsTask, rulesTask
            )

            self.accounts = accs
            self.categories = cats
            self.recentTransactions = txs.items
            self.monthSummary = summary
            self.categoryBreakdown = breakdown
            self.savingsGoals = savings
            self.upcomingBills = bills
            self.recurringRules = rules
            self.lastSyncDate = Date()
        } catch {
            self.errorMessage = error.localizedDescription
            print("Sync error: \(error)")
        }

        self.isLoading = false
    }

    public func changeMonth(year: Int, month: Int) async {
        self.selectedYear = year
        self.selectedMonth = month
        await refreshAll()
    }

    public func addTransaction(
        date: String,
        amount: Double,
        type: TransactionType,
        categoryId: Int?,
        accountId: Int?,
        destinationAccountId: Int? = nil,
        payee: String,
        description: String,
        notes: String = "",
        tags: String = ""
    ) async throws {
        self.isSyncing = true
        defer { self.isSyncing = false }

        do {
            _ = try await api.createTransaction(
                date: date,
                amount: amount,
                type: type.rawValue,
                categoryId: categoryId,
                accountId: accountId,
                destinationAccountId: destinationAccountId,
                payee: payee,
                description: description,
                notes: notes,
                tags: tags
            )
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            // Queue offline
            let queued = QueuedTransaction(
                id: UUID().uuidString,
                date: date,
                amount: amount,
                type: type.rawValue,
                categoryId: categoryId,
                accountId: accountId,
                destinationAccountId: destinationAccountId,
                payee: payee,
                description: description,
                notes: notes,
                tags: tags,
                createdAt: Date()
            )
            offlineQueue.enqueue(queued)
            HapticManager.notification(.warning)
            self.errorMessage = "Transactie lokaal opgeslagen. Wordt verzonden zodra er verbinding is."
        }
    }

    public func deleteTransaction(id: Int) async {
        do {
            try await api.deleteTransaction(id: id)
            self.recentTransactions.removeAll { $0.id == id }
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func contributeToSavingsGoal(id: Int, amount: Double) async throws {
        _ = try await api.contributeSavingsGoal(id: id, amount: amount)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func generateRecurringBill(ruleId: Int) async {
        do {
            _ = try await api.generateRecurringTransaction(ruleId: ruleId, year: selectedYear, month: selectedMonth)
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func upsertBudget(categoryId: Int, amount: Double) async throws {
        _ = try await api.upsertBudget(categoryId: categoryId, amount: amount)
        HapticManager.notification(.success)
        await refreshAll()
    }
}
