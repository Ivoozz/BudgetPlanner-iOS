import Foundation

public struct UserProfile: Codable, Hashable {
    public let authenticated: Bool
    public let username: String?
    public let lastLogin: String?

    enum CodingKeys: String, CodingKey {
        case authenticated, username
        case lastLogin = "last_login"
    }
}

public struct AuthResponse: Codable {
    public let accessToken: String
    public let tokenType: String
    public let username: String

    enum CodingKeys: String, CodingKey {
        case username
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

public struct AuthStatus: Codable {
    public let isSetup: Bool
    public let userCount: Int

    enum CodingKeys: String, CodingKey {
        case isSetup = "is_setup"
        case userCount = "user_count"
    }
}
