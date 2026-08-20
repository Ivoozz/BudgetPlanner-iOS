import Foundation

public struct Budget: Identifiable, Codable, Hashable {
    public let id: Int
    public var categoryId: Int
    public var amount: Double
    public var periodYear: Int?
    public var periodMonth: Int?
    public var category: Category?

    enum CodingKeys: String, CodingKey {
        case id, amount, category
        case categoryId = "category_id"
        case periodYear = "period_year"
        case periodMonth = "period_month"
    }

    public init(
        id: Int,
        categoryId: Int,
        amount: Double,
        periodYear: Int? = nil,
        periodMonth: Int? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.amount = amount
        self.periodYear = periodYear
        self.periodMonth = periodMonth
        self.category = category
    }
}
