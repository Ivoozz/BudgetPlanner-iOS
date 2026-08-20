import Foundation

public struct Account: Identifiable, Codable, Hashable {
    public let id: Int
    public var name: String
    public var type: AccountType
    public var balance: Double
    public var initialBalance: Double?
    public var currency: String
    public var icon: String
    public var color: String
    public var isArchived: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, type, balance, currency, icon, color
        case initialBalance = "initial_balance"
        case isArchived = "is_archived"
    }

    public init(
        id: Int,
        name: String,
        type: AccountType = .checking,
        balance: Double = 0.0,
        initialBalance: Double? = 0.0,
        currency: String = "EUR",
        icon: String = "creditcard.fill",
        color: String = "#3B82F6",
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.initialBalance = initialBalance
        self.currency = currency
        self.icon = icon
        self.color = color
        self.isArchived = isArchived
    }
}

public enum AccountType: String, Codable, CaseIterable, Identifiable {
    case checking = "checking"
    case savings = "savings"
    case investment = "investment"
    case creditCard = "credit_card"
    case cash = "cash"
    case debt = "debt"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .checking: return "Betaalrekening"
        case .savings: return "Spaarrekening"
        case .investment: return "Beleggingen"
        case .creditCard: return "Creditcard"
        case .cash: return "Contant"
        case .debt: return "Lening / Schuld"
        }
    }

    public var defaultIcon: String {
        switch self {
        case .checking: return "creditcard.fill"
        case .savings: return "building.columns.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .creditCard: return "creditcard.and.123"
        case .cash: return "banknote.fill"
        case .debt: return "arrow.down.right.and.arrow.up.left"
        }
    }
}
