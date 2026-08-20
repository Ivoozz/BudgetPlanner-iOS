import Foundation
import Combine

public class AuthManager: ObservableObject {
    public static let shared = AuthManager()

    @Published public var isAuthenticated: Bool = false
    @Published public var currentUser: String? = nil
    @Published public var serverURL: String = "https://budget.ivoozz.nl"
    @Published public var isBiometricsEnabled: Bool = false

    private init() {
        self.serverURL = UserDefaults.standard.string(forKey: "server_url") ?? "https://budget.ivoozz.nl"
        self.currentUser = UserDefaults.standard.string(forKey: "current_username")
        self.isBiometricsEnabled = UserDefaults.standard.bool(forKey: "biometrics_enabled")
        
        let token = UserDefaults.standard.string(forKey: "auth_token")
        self.isAuthenticated = (token != nil && !token!.isEmpty)
    }

    public func setServerURL(_ url: String) {
        var clean = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasSuffix("/") {
            clean.removeLast()
        }
        self.serverURL = clean
        UserDefaults.standard.set(clean, forKey: "server_url")
    }

    public func login(username: String, token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
        UserDefaults.standard.set(username, forKey: "current_username")
        self.currentUser = username
        self.isAuthenticated = true
    }

    public func logout() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "current_username")
        self.currentUser = nil
        self.isAuthenticated = false
    }

    public func setBiometricsEnabled(_ enabled: Bool) {
        self.isBiometricsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "biometrics_enabled")
    }
}
