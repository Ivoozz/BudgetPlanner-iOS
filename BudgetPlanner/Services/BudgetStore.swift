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

    @Published public var privacyMode: Bool = UserDefaults.standard.bool(forKey: "privacy_mode")
    @Published public var isLoading: Bool = false
    @Published public var isSyncing: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var lastSyncDate: Date? = nil

    private let api = APIService.shared
    private let offlineQueue = OfflineQueueManager.shared

    public init() {}

    public var isCurrentMonth: Bool {
        let now = Date()
        let cal = Calendar.current
        return selectedYear == cal.component(.year, from: now) && selectedMonth == cal.component(.month, from: now)
    }

    public var totalBalance: Double {
        accounts.filter { !$0.isArchived }.reduce(0.0) { $0 + $1.balance }
    }

    public var checkingAccounts: [Account] {
        accounts.filter { $0.type == .checking && !$0.isArchived }
    }

    public var savingsAccounts: [Account] {
        accounts.filter { $0.type == .savings && !$0.isArchived }
    }

    public var creditCardAccounts: [Account] {
        accounts.filter { $0.type == .creditCard && !$0.isArchived }
    }

    public var investmentAccounts: [Account] {
        accounts.filter { $0.type == .investment && !$0.isArchived }
    }

    // Recurring computations
    public var incomeRecurringRules: [RecurringRule] {
        recurringRules.filter { $0.type == "income" && $0.isActive }
    }

    public var expenseRecurringRules: [RecurringRule] {
        recurringRules.filter { $0.type != "income" && $0.isActive }
    }

    public var totalMonthlyIncome: Double {
        incomeRecurringRules.reduce(0.0) { $0 + $1.monthlyEquivalent }
    }

    public var totalMonthlyExpense: Double {
        expenseRecurringRules.reduce(0.0) { $0 + $1.monthlyEquivalent }
    }

    public var netFixedRemaining: Double {
        totalMonthlyIncome - totalMonthlyExpense
    }

    // MARK: - Privacy Toggle
    public func togglePrivacy() {
        self.privacyMode.toggle()
        UserDefaults.standard.set(self.privacyMode, forKey: "privacy_mode")
        HapticManager.impact(.light)
    }

    // MARK: - Navigation
    public func changeMonth(delta: Int) async {
        var m = selectedMonth + delta
        var y = selectedYear
        if m < 1 {
            m = 12
            y -= 1
        } else if m > 12 {
            m = 1
            y += 1
        }
        self.selectedMonth = m
        self.selectedYear = y
        HapticManager.selection()
        await refreshAll()
    }

    public func resetToCurrentMonth() async {
        let now = Date()
        let cal = Calendar.current
        self.selectedYear = cal.component(.year, from: now)
        self.selectedMonth = cal.component(.month, from: now)
        HapticManager.selection()
        await refreshAll()
    }

    // MARK: - Data Synchronization
    public func refreshAll() async {
        guard AuthManager.shared.isAuthenticated else { return }

        self.isLoading = true
        self.errorMessage = nil

        // 1. Flush offline queue
        await offlineQueue.flushQueue()

        do {
            async let accsTask = api.getAccounts(includeArchived: true)
            async let catsTask = api.getCategories()
            async let txsTask = api.getTransactions(year: selectedYear, month: selectedMonth, limit: 100)
            async let summaryTask = api.getMonthSummary(year: selectedYear, month: selectedMonth)
            async let breakdownTask = api.getCategoryBreakdown(year: selectedYear, month: selectedMonth)
            async let savingsTask = api.getSavingsGoals()
            async let billsTask = api.getUpcomingBills(days: 30)
            async let rulesTask = api.getRecurringRules()
            async let cashflowTask = api.getCashflowTrend(year: selectedYear)

            let (accs, cats, txs, summary, breakdown, savings, bills, rules, cashflow) = try await (
                accsTask, catsTask, txsTask, summaryTask, breakdownTask, savingsTask, billsTask, rulesTask, cashflowTask
            )

            self.accounts = accs
            self.categories = cats
            self.recentTransactions = txs.items
            self.monthSummary = summary
            self.categoryBreakdown = breakdown
            self.savingsGoals = savings
            self.upcomingBills = bills
            self.recurringRules = rules
            self.cashflowTrends = cashflow
            self.lastSyncDate = Date()
        } catch {
            self.errorMessage = error.localizedDescription
            print("Sync error: \(error)")
        }

        self.isLoading = false
    }

    // MARK: - Transactions
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

    public func updateTransaction(id: Int, payload: [String: Any]) async throws {
        _ = try await api.updateTransaction(id: id, payload: payload)
        HapticManager.notification(.success)
        await refreshAll()
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

    // MARK: - Accounts
    public func addAccount(name: String, type: String, balance: Double, icon: String, color: String) async throws {
        _ = try await api.createAccount(name: name, type: type, balance: balance, icon: icon, color: color)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func updateAccount(id: Int, name: String, type: String, icon: String, color: String) async throws {
        _ = try await api.updateAccount(id: id, name: name, type: type, icon: icon, color: color)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func deleteAccount(id: Int) async {
        do {
            try await api.deleteAccount(id: id)
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Categories
    public func addCategory(name: String, type: String, icon: String, color: String) async throws {
        _ = try await api.createCategory(name: name, type: type, icon: icon, color: color)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func updateCategory(id: Int, name: String, type: String, icon: String, color: String) async throws {
        _ = try await api.updateCategory(id: id, name: name, type: type, icon: icon, color: color)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func deleteCategory(id: Int) async {
        do {
            try await api.deleteCategory(id: id)
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Recurring Rules
    public func addRecurringRule(
        name: String,
        amount: Double,
        type: String,
        frequency: String,
        dayOfMonth: Int,
        categoryId: Int?,
        accountId: Int?,
        payee: String,
        startDate: String,
        notes: String
    ) async throws {
        _ = try await api.createRecurringRule(
            name: name,
            amount: amount,
            type: type,
            frequency: frequency,
            dayOfMonth: dayOfMonth,
            categoryId: categoryId,
            accountId: accountId,
            payee: payee,
            startDate: startDate,
            notes: notes
        )
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func updateRecurringRule(id: Int, payload: [String: Any]) async throws {
        _ = try await api.updateRecurringRule(id: id, payload: payload)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func deleteRecurringRule(id: Int) async {
        do {
            try await api.deleteRecurringRule(id: id)
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
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

    // MARK: - Savings Goals
    public func addSavingsGoal(
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        targetDate: String?,
        accountId: Int?,
        categoryId: Int?,
        color: String,
        icon: String
    ) async throws {
        _ = try await api.createSavingsGoal(
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: targetDate,
            accountId: accountId,
            categoryId: categoryId,
            color: color,
            icon: icon
        )
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func updateSavingsGoal(id: Int, payload: [String: Any]) async throws {
        _ = try await api.updateSavingsGoal(id: id, payload: payload)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func contributeToSavingsGoal(id: Int, amount: Double) async throws {
        _ = try await api.contributeSavingsGoal(id: id, amount: amount)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func deleteSavingsGoal(id: Int) async {
        do {
            try await api.deleteSavingsGoal(id: id)
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Budgets
    public func upsertBudget(categoryId: Int, amount: Double) async throws {
        _ = try await api.upsertBudget(categoryId: categoryId, amount: amount, year: selectedYear, month: selectedMonth)
        HapticManager.notification(.success)
        await refreshAll()
    }

    public func deleteBudget(id: Int) async {
        do {
            try await api.deleteBudget(id: id)
            HapticManager.notification(.success)
            await refreshAll()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - System Tools
    public func seedDemoData() async throws -> String {
        let msg = try await api.seedDemoData()
        await refreshAll()
        return msg
    }

    public func resetDatabase() async throws -> String {
        let msg = try await api.resetDatabase()
        await refreshAll()
        return msg
    }
}
