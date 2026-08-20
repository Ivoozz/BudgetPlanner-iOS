import Foundation

public enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case unauthorized
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ongeldige server URL"
        case .invalidResponse:
            return "Ongeldige respons van de server"
        case .httpError(let code, let msg):
            return "Server fout (\(code)): \(msg)"
        case .decodingError(let err):
            return "Fout bij verwerken van data: \(err.localizedDescription)"
        case .unauthorized:
            return "Niet ingelogd of sessie verlopen. Log opnieuw in."
        case .networkError(let err):
            return "Netwerkfout: \(err.localizedDescription)"
        }
    }
}

public class APIService {
    public static let shared = APIService()

    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
        
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
    }

    private var baseURL: String {
        UserDefaults.standard.string(forKey: "server_url") ?? "https://budget.ivoozz.nl"
    }

    private var token: String? {
        UserDefaults.standard.string(forKey: "auth_token")
    }

    private func createRequest(path: String, method: String = "GET", body: Data? = nil, queryItems: [URLQueryItem]? = nil) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            var msg = "HTTP \(httpResponse.statusCode)"
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                msg = detail
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: msg)
        }

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Auth
    public func getAuthStatus() async throws -> AuthStatus {
        let req = try createRequest(path: "/api/auth/status")
        return try await execute(req)
    }

    public func login(username: String, password: String) async throws -> AuthResponse {
        let payload = ["username": username, "password": password]
        let body = try jsonEncoder.encode(payload)
        let req = try createRequest(path: "/api/auth/login", method: "POST", body: body)
        return try await execute(req)
    }

    public func getCurrentUser() async throws -> UserProfile {
        let req = try createRequest(path: "/api/auth/me")
        return try await execute(req)
    }

    public func changePassword(oldPassword: String, newPassword: String) async throws -> String {
        let payload = ["old_password": oldPassword, "new_password": newPassword]
        let body = try jsonEncoder.encode(payload)
        let req = try createRequest(path: "/api/auth/change-password", method: "POST", body: body)
        let res: [String: String] = try await execute(req)
        return res["message"] ?? "Wachtwoord succesvol gewijzigd."
    }

    // MARK: - Accounts
    public func getAccounts(includeArchived: Bool = false) async throws -> [Account] {
        let q = [URLQueryItem(name: "include_archived", value: String(includeArchived))]
        let req = try createRequest(path: "/api/accounts", queryItems: q)
        return try await execute(req)
    }

    public func createAccount(name: String, type: String, balance: Double, icon: String, color: String) async throws -> Account {
        let payload: [String: Any] = [
            "name": name,
            "type": type,
            "balance": balance,
            "initial_balance": balance,
            "currency": "EUR",
            "icon": icon,
            "color": color
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/accounts", method: "POST", body: body)
        return try await execute(req)
    }

    public func updateAccount(id: Int, name: String, type: String? = nil, icon: String, color: String) async throws -> Account {
        var payload: [String: Any] = [
            "name": name,
            "icon": icon,
            "color": color
        ]
        if let t = type { payload["type"] = t }
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/accounts/\(id)", method: "PUT", body: body)
        return try await execute(req)
    }

    public func deleteAccount(id: Int) async throws {
        let req = try createRequest(path: "/api/accounts/\(id)", method: "DELETE")
        let _: [String: String] = try await execute(req)
    }

    // MARK: - Categories
    public func getCategories(type: String? = nil) async throws -> [Category] {
        var q: [URLQueryItem] = []
        if let type = type {
            q.append(URLQueryItem(name: "type", value: type))
        }
        let req = try createRequest(path: "/api/categories", queryItems: q)
        return try await execute(req)
    }

    public func createCategory(name: String, type: String, icon: String, color: String) async throws -> Category {
        let payload: [String: Any] = [
            "name": name,
            "type": type,
            "icon": icon,
            "color": color
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/categories", method: "POST", body: body)
        return try await execute(req)
    }

    public func updateCategory(id: Int, name: String, type: String, icon: String, color: String) async throws -> Category {
        let payload: [String: Any] = [
            "name": name,
            "type": type,
            "icon": icon,
            "color": color
        ]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/categories/\(id)", method: "PUT", body: body)
        return try await execute(req)
    }

    public func deleteCategory(id: Int) async throws {
        let req = try createRequest(path: "/api/categories/\(id)", method: "DELETE")
        let _: [String: String] = try await execute(req)
    }

    // MARK: - Transactions
    public func getTransactions(
        year: Int? = nil,
        month: Int? = nil,
        type: String? = nil,
        categoryId: Int? = nil,
        accountId: Int? = nil,
        search: String? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> TransactionListResponse {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        if let year = year { q.append(URLQueryItem(name: "year", value: "\(year)")) }
        if let month = month { q.append(URLQueryItem(name: "month", value: "\(month)")) }
        if let type = type { q.append(URLQueryItem(name: "type", value: type)) }
        if let categoryId = categoryId { q.append(URLQueryItem(name: "category_id", value: "\(categoryId)")) }
        if let accountId = accountId { q.append(URLQueryItem(name: "account_id", value: "\(accountId)")) }
        if let search = search, !search.isEmpty { q.append(URLQueryItem(name: "search", value: search)) }

        let req = try createRequest(path: "/api/transactions", queryItems: q)
        return try await execute(req)
    }

    public func createTransaction(
        date: String,
        amount: Double,
        type: String,
        categoryId: Int?,
        accountId: Int?,
        destinationAccountId: Int? = nil,
        payee: String = "",
        description: String = "",
        notes: String = "",
        tags: String = ""
    ) async throws -> Transaction {
        var payload: [String: Any] = [
            "date": date,
            "amount": amount,
            "type": type,
            "payee": payee,
            "description": description,
            "notes": notes,
            "tags": tags,
            "is_cleared": true
        ]
        if let catId = categoryId { payload["category_id"] = catId }
        if let accId = accountId { payload["account_id"] = accId }
        if let dstId = destinationAccountId { payload["destination_account_id"] = dstId }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/transactions", method: "POST", body: body)
        return try await execute(req)
    }

    public func updateTransaction(id: Int, payload: [String: Any]) async throws -> Transaction {
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/transactions/\(id)", method: "PUT", body: body)
        return try await execute(req)
    }

    public func deleteTransaction(id: Int) async throws {
        let req = try createRequest(path: "/api/transactions/\(id)", method: "DELETE")
        let _: [String: String] = try await execute(req)
    }

    // MARK: - Budgets
    public func getBudgets() async throws -> [Budget] {
        let req = try createRequest(path: "/api/budgets")
        return try await execute(req)
    }

    public func upsertBudget(categoryId: Int, amount: Double, year: Int? = nil, month: Int? = nil) async throws -> Budget {
        var payload: [String: Any] = [
            "category_id": categoryId,
            "amount": amount
        ]
        if let y = year { payload["period_year"] = y }
        if let m = month { payload["period_month"] = m }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/budgets", method: "POST", body: body)
        return try await execute(req)
    }

    public func deleteBudget(id: Int) async throws {
        let req = try createRequest(path: "/api/budgets/\(id)", method: "DELETE")
        let _: [String: String] = try await execute(req)
    }

    // MARK: - Savings Goals
    public func getSavingsGoals() async throws -> [SavingsGoal] {
        let req = try createRequest(path: "/api/savings-goals")
        return try await execute(req)
    }

    public func createSavingsGoal(
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0.0,
        targetDate: String? = nil,
        accountId: Int? = nil,
        categoryId: Int? = nil,
        color: String = "#10B981",
        icon: String = "target"
    ) async throws -> SavingsGoal {
        var payload: [String: Any] = [
            "name": name,
            "target_amount": targetAmount,
            "current_amount": currentAmount,
            "color": color,
            "icon": icon,
            "notes": ""
        ]
        if let td = targetDate { payload["target_date"] = td }
        if let aid = accountId { payload["account_id"] = aid }
        if let cid = categoryId { payload["category_id"] = cid }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/savings-goals", method: "POST", body: body)
        return try await execute(req)
    }

    public func updateSavingsGoal(id: Int, payload: [String: Any]) async throws -> SavingsGoal {
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/savings-goals/\(id)", method: "PUT", body: body)
        return try await execute(req)
    }

    public func contributeSavingsGoal(id: Int, amount: Double) async throws -> SavingsGoal {
        let q = [URLQueryItem(name: "amount", value: "\(amount)")]
        let req = try createRequest(path: "/api/savings-goals/\(id)/contribute", method: "POST", queryItems: q)
        return try await execute(req)
    }

    public func deleteSavingsGoal(id: Int) async throws {
        let req = try createRequest(path: "/api/savings-goals/\(id)", method: "DELETE")
        let _: [String: String] = try await execute(req)
    }

    // MARK: - Recurring Rules
    public func getRecurringRules() async throws -> [RecurringRule] {
        let req = try createRequest(path: "/api/recurring")
        return try await execute(req)
    }

    public func createRecurringRule(
        name: String,
        amount: Double,
        type: String,
        frequency: String,
        dayOfMonth: Int,
        categoryId: Int?,
        accountId: Int?,
        payee: String = "",
        startDate: String,
        notes: String = ""
    ) async throws -> RecurringRule {
        var payload: [String: Any] = [
            "name": name,
            "amount": amount,
            "type": type,
            "frequency": frequency,
            "day_of_month": dayOfMonth,
            "payee": payee,
            "start_date": startDate,
            "notes": notes,
            "is_active": true
        ]
        if let cid = categoryId { payload["category_id"] = cid }
        if let aid = accountId { payload["account_id"] = aid }

        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/recurring", method: "POST", body: body)
        return try await execute(req)
    }

    public func updateRecurringRule(id: Int, payload: [String: Any]) async throws -> RecurringRule {
        let body = try JSONSerialization.data(withJSONObject: payload)
        let req = try createRequest(path: "/api/recurring/\(id)", method: "PUT", body: body)
        return try await execute(req)
    }

    public func deleteRecurringRule(id: Int) async throws {
        let req = try createRequest(path: "/api/recurring/\(id)", method: "DELETE")
        let _: [String: String] = try await execute(req)
    }

    public func generateRecurringTransaction(ruleId: Int, year: Int, month: Int) async throws -> [String: Any] {
        let q = [
            URLQueryItem(name: "year", value: "\(year)"),
            URLQueryItem(name: "month", value: "\(month)")
        ]
        let req = try createRequest(path: "/api/recurring/\(ruleId)/generate-transaction", method: "POST", queryItems: q)
        let (data, _): (Data, URLResponse) = try await session.data(for: req)
        return (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
    }

    // MARK: - Analytics & Stats
    public func getMonthSummary(year: Int, month: Int) async throws -> MonthSummary {
        let q = [
            URLQueryItem(name: "year", value: "\(year)"),
            URLQueryItem(name: "month", value: "\(month)")
        ]
        let req = try createRequest(path: "/api/stats/summary", queryItems: q)
        return try await execute(req)
    }

    public func getCategoryBreakdown(year: Int, month: Int) async throws -> [CategoryBreakdownItem] {
        let q = [
            URLQueryItem(name: "year", value: "\(year)"),
            URLQueryItem(name: "month", value: "\(month)")
        ]
        let req = try createRequest(path: "/api/stats/categories", queryItems: q)
        return try await execute(req)
    }

    public func getUpcomingBills(days: Int = 30) async throws -> [UpcomingBill] {
        let q = [URLQueryItem(name: "days", value: "\(days)")]
        let req = try createRequest(path: "/api/stats/upcoming", queryItems: q)
        return try await execute(req)
    }

    public func getCashflowTrend(year: Int) async throws -> [CashFlowPoint] {
        let q = [URLQueryItem(name: "year", value: "\(year)")]
        let req = try createRequest(path: "/api/stats/cashflow", queryItems: q)
        return try await execute(req)
    }

    // MARK: - System Tools
    public func seedDemoData() async throws -> String {
        let req = try createRequest(path: "/api/system/seed-demo", method: "POST")
        let res: [String: String] = try await execute(req)
        return res["message"] ?? "Voorbeelddata succesvol geladen!"
    }

    public func resetDatabase() async throws -> String {
        let req = try createRequest(path: "/api/system/reset", method: "POST")
        let res: [String: String] = try await execute(req)
        return res["message"] ?? "Database geschoond."
    }
}
