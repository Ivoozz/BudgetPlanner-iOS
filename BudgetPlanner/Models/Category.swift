import Foundation

public struct Category: Identifiable, Codable, Hashable {
    public let id: Int
    public var name: String
    public var type: CategoryType
    public var icon: String
    public var color: String
    public var isSystem: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, type, icon, color
        case isSystem = "is_system"
    }

    public init(
        id: Int,
        name: String,
        type: CategoryType = .variableExpense,
        icon: String = "tag.fill",
        color: String = "#64748B",
        isSystem: Bool? = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.icon = icon
        self.color = color
        self.isSystem = isSystem
    }
}

public enum CategoryType: String, Codable, CaseIterable, Identifiable {
    case income = "income"
    case fixedExpense = "fixed_expense"
    case variableExpense = "variable_expense"
    case oneTimeExpense = "one_time_expense"
    case savings = "savings"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .income: return "Inkomsten"
        case .fixedExpense: return "Vaste Lasten"
        case .variableExpense: return "Variabele Uitgaven"
        case .oneTimeExpense: return "Eenmalige Uitgaven"
        case .savings: return "Sparen & Beleggen"
        }
    }

    public var isExpense: Bool {
        self == .fixedExpense || self == .variableExpense || self == .oneTimeExpense
    }
}
