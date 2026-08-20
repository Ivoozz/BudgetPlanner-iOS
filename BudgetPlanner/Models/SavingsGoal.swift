import Foundation

public struct SavingsGoal: Identifiable, Codable, Hashable {
    public let id: Int
    public var name: String
    public var targetAmount: Double
    public var currentAmount: Double
    public var targetDate: String?
    public var accountId: Int?
    public var categoryId: Int?
    public var color: String
    public var icon: String
    public var notes: String
    public var isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, color, icon, notes
        case targetAmount = "target_amount"
        case currentAmount = "current_amount"
        case targetDate = "target_date"
        case accountId = "account_id"
        case categoryId = "category_id"
        case isCompleted = "is_completed"
    }

    public var progress: Double {
        guard targetAmount > 0 else { return 0.0 }
        return min(1.0, max(0.0, currentAmount / targetAmount))
    }

    public var remainingAmount: Double {
        max(0.0, targetAmount - currentAmount)
    }

    public init(
        id: Int,
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0.0,
        targetDate: String? = nil,
        accountId: Int? = nil,
        categoryId: Int? = nil,
        color: String = "#10B981",
        icon: String = "target",
        notes: String = "",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.accountId = accountId
        self.categoryId = categoryId
        self.color = color
        self.icon = icon
        self.notes = notes
        self.isCompleted = isCompleted
    }
}
