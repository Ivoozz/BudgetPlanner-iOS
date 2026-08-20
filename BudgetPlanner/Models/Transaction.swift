import Foundation

public struct Transaction: Identifiable, Codable, Hashable {
    public let id: Int
    public var date: String // YYYY-MM-DD
    public var amount: Double
    public var type: TransactionType
    public var categoryId: Int?
    public var accountId: Int?
    public var destinationAccountId: Int?
    public var recurringRuleId: Int?
    public var payee: String
    public var description: String
    public var notes: String
    public var tags: String
    public var isCleared: Bool
    
    public var category: CategoryBrief?
    public var account: AccountBrief?

    enum CodingKeys: String, CodingKey {
        case id, date, amount, type, payee, description, notes, tags
        case categoryId = "category_id"
        case accountId = "account_id"
        case destinationAccountId = "destination_account_id"
        case recurringRuleId = "recurring_rule_id"
        case isCleared = "is_cleared"
        case category, account
    }

    public init(
        id: Int,
        date: String,
        amount: Double,
        type: TransactionType,
        categoryId: Int? = nil,
        accountId: Int? = nil,
        destinationAccountId: Int? = nil,
        recurringRuleId: Int? = nil,
        payee: String = "",
        description: String = "",
        notes: String = "",
        tags: String = "",
        isCleared: Bool = true,
        category: CategoryBrief? = nil,
        account: AccountBrief? = nil
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.accountId = accountId
        self.destinationAccountId = destinationAccountId
        self.recurringRuleId = recurringRuleId
        self.payee = payee
        self.description = description
        self.notes = notes
        self.tags = tags
        self.isCleared = isCleared
        self.category = category
        self.account = account
    }
}

public struct CategoryBrief: Codable, Hashable {
    public let id: Int
    public let name: String
    public let type: String?
    public let icon: String?
    public let color: String?
}

public struct AccountBrief: Codable, Hashable {
    public let id: Int
    public let name: String
    public let icon: String?
    public let color: String?
}

public enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income = "income"
    case fixedExpense = "fixed_expense"
    case variableExpense = "variable_expense"
    case oneTimeExpense = "one_time_expense"
    case savings = "savings"
    case transfer = "transfer"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .income: return "Inkomst"
        case .fixedExpense: return "Vaste Last"
        case .variableExpense: return "Variabele Uitgave"
        case .oneTimeExpense: return "Eenmalige Uitgave"
        case .savings: return "Sparen"
        case .transfer: return "Overboeking"
        }
    }

    public var isExpense: Bool {
        self == .fixedExpense || self == .variableExpense || self == .oneTimeExpense
    }
}

public struct TransactionListResponse: Codable {
    public let total: Int
    public let items: [Transaction]
}
