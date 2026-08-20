import Foundation

public struct RecurringRule: Identifiable, Codable, Hashable {
    public let id: Int
    public var name: String
    public var amount: Double
    public var type: String
    public var frequency: String
    public var dayOfMonth: Int
    public var categoryId: Int?
    public var accountId: Int?
    public var payee: String
    public var startDate: String
    public var endDate: String?
    public var isActive: Bool
    public var notes: String

    enum CodingKeys: String, CodingKey {
        case id, name, amount, type, frequency, payee, notes
        case dayOfMonth = "day_of_month"
        case categoryId = "category_id"
        case accountId = "account_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case isActive = "is_active"
    }

    public init(
        id: Int,
        name: String,
        amount: Double,
        type: String = "fixed_expense",
        frequency: String = "monthly",
        dayOfMonth: Int = 1,
        categoryId: Int? = nil,
        accountId: Int? = nil,
        payee: String = "",
        startDate: String = "",
        endDate: String? = nil,
        isActive: Bool = true,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.type = type
        self.frequency = frequency
        self.dayOfMonth = dayOfMonth
        self.categoryId = categoryId
        self.accountId = accountId
        self.payee = payee
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.notes = notes
    }

    public var monthlyEquivalent: Double {
        switch frequency {
        case "weekly": return amount * 4.333
        case "quarterly": return amount / 3.0
        case "semi_annually": return amount / 6.0
        case "annually": return amount / 12.0
        default: return amount
        }
    }

    public var frequencyLabel: String {
        switch frequency {
        case "weekly": return "Wekelijks"
        case "monthly": return "Maandelijks"
        case "quarterly": return "Per kwartaal"
        case "semi_annually": return "Halfjaarlijks"
        case "annually": return "Jaarlijks"
        default: return frequency.capitalized
        }
    }
}

public struct UpcomingBill: Identifiable, Codable, Hashable {
    public var id: Int { ruleId }
    public let ruleId: Int
    public let name: String
    public let amount: Double
    public let type: String
    public let payee: String?
    public let dueDate: String
    public let daysUntil: Int
    public let category: CategoryBrief?

    enum CodingKeys: String, CodingKey {
        case name, amount, type, payee, category
        case ruleId = "rule_id"
        case dueDate = "due_date"
        case daysUntil = "days_until"
    }
}
