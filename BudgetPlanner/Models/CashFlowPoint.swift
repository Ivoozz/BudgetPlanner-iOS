import Foundation

public struct CashFlowPoint: Identifiable, Codable, Hashable {
    public var id: String { "\(year)-\(month)" }
    public let label: String
    public let year: Int
    public let month: Int
    public let income: Double
    public let fixedExpenses: Double
    public let variableExpenses: Double
    public let oneTimeExpenses: Double
    public let totalExpenses: Double
    public let netSavings: Double

    enum CodingKeys: String, CodingKey {
        case label, year, month, income
        case fixedExpenses = "fixed_expenses"
        case variableExpenses = "variable_expenses"
        case oneTimeExpenses = "one_time_expenses"
        case totalExpenses = "total_expenses"
        case netSavings = "net_savings"
    }
}
