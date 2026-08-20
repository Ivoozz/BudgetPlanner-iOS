import Foundation

public struct MonthSummary: Codable, Hashable {
    public let year: Int
    public let month: Int
    public let totalIncome: Double
    public let totalFixedExpenses: Double
    public let totalVariableExpenses: Double
    public let totalOneTimeExpenses: Double
    public let totalExpenses: Double
    public let totalSavings: Double
    public let netSavings: Double
    public let savingsRate: Double
    public let dailyBudgetRemaining: Double
    public let daysLeftInMonth: Int
    public let prevMonthIncome: Double
    public let prevMonthExpenses: Double

    enum CodingKeys: String, CodingKey {
        case year, month
        case totalIncome = "total_income"
        case totalFixedExpenses = "total_fixed_expenses"
        case totalVariableExpenses = "total_variable_expenses"
        case totalOneTimeExpenses = "total_one_time_expenses"
        case totalExpenses = "total_expenses"
        case totalSavings = "total_savings"
        case netSavings = "net_savings"
        case savingsRate = "savings_rate"
        case dailyBudgetRemaining = "daily_budget_remaining"
        case daysLeftInMonth = "days_left_in_month"
        case prevMonthIncome = "prev_month_income"
        case prevMonthExpenses = "prev_month_expenses"
    }

    public static var empty: MonthSummary {
        MonthSummary(
            year: Calendar.current.component(.year, from: Date()),
            month: Calendar.current.component(.month, from: Date()),
            totalIncome: 0,
            totalFixedExpenses: 0,
            totalVariableExpenses: 0,
            totalOneTimeExpenses: 0,
            totalExpenses: 0,
            totalSavings: 0,
            netSavings: 0,
            savingsRate: 0,
            dailyBudgetRemaining: 0,
            daysLeftInMonth: 1,
            prevMonthIncome: 0,
            prevMonthExpenses: 0
        )
    }
}

public struct CategoryBreakdownItem: Identifiable, Codable, Hashable {
    public var id: Int { categoryId ?? -1 }
    public let categoryId: Int?
    public let categoryName: String
    public let categoryColor: String
    public let categoryIcon: String
    public let categoryType: String
    public let totalAmount: Double
    public let percentage: Double
    public let budgetAmount: Double?
    public let budgetUsedPercentage: Double?
    public let remainingBudget: Double?

    enum CodingKeys: String, CodingKey {
        case percentage
        case categoryId = "category_id"
        case categoryName = "category_name"
        case categoryColor = "category_color"
        case categoryIcon = "category_icon"
        case categoryType = "category_type"
        case totalAmount = "total_amount"
        case budgetAmount = "budget_amount"
        case budgetUsedPercentage = "budget_used_percentage"
        case remainingBudget = "remaining_budget"
    }
}
