import Foundation
import LocalAuthentication

public class BiometricAuthManager {
    public static let shared = BiometricAuthManager()

    private init() {}

    public func canEvaluateBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public func authenticate(reason: String = "Ontgrendel BudgetPlanner met Face ID") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Annuleren"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Biometrics not available on device or simulator
            return true
        }

        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch {
            return false
        }
    }
}
