import SwiftUI

public struct LoginView: View {
    @ObservedObject var auth = AuthManager.shared
    @ObservedObject var store = BudgetStore.shared

    @State private var username = ""
    @State private var password = ""
    @State private var serverURL = "https://budget.ivoozz.nl"
    @State private var isCustomServer = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var isServerReachable: Bool? = nil

    public init() {}

    public var body: some View {
        ZStack {
            LiquidBackground()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 40)

                    // App Logo & Header
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appEmerald.opacity(0.8), Color.appSapphire.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 88, height: 88)
                                .shadow(color: Color.appEmerald.opacity(0.4), radius: 20, x: 0, y: 10)

                            Image(systemName: "eurosign.circle.fill")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("BudgetPlanner")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Persoonlijk Financieel Cockpit")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // Login Card
                    VStack(spacing: 18) {
                        // Username
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Gebruikersnaam")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)

                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)

                                TextField("Gebruikersnaam", text: $username)
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Wachtwoord")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 20)

                                SecureField("Wachtwoord", text: $password)
                                    .textContentType(.password)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }

                        // Server URL toggle / config
                        if isCustomServer {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Server URL")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)

                                HStack {
                                    Image(systemName: "server.rack")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)

                                    TextField("https://budget.ivoozz.nl", text: $serverURL)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .keyboardType(.URL)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(14)
                            }
                        }

                        Button(action: {
                            withAnimation { isCustomServer.toggle() }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: isCustomServer ? "chevron.up" : "gearshape")
                                Text(isCustomServer ? "Standaard server gebruiken" : "Aangepaste server URL")
                            }
                            .font(.caption)
                            .foregroundColor(.appSapphire)
                        }

                        if let err = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(err)
                                    .font(.footnote)
                            }
                            .foregroundColor(.appRose)
                            .padding(.vertical, 4)
                        }

                        // Submit Button
                        Button(action: handleLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Inloggen & Synchroniseren")
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.appEmerald, Color(hex: "#059669")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.appEmerald.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoading || username.isEmpty || password.isEmpty)
                        .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(24)
                    .liquidGlass(cornerRadius: 24)
                    .padding(.horizontal, 20)

                    // Footer info
                    VStack(spacing: 6) {
                        Text("Verbonden met jouw privé Proxmox homelab")
                            .font(.caption2)
                            .foregroundColor(.gray)

                        Text("https://budget.ivoozz.nl")
                            .font(.caption2)
                            .foregroundColor(.appEmerald.opacity(0.8))
                    }

                    Spacer(minLength: 30)
                }
            }
        }
        .onAppear {
            self.serverURL = auth.serverURL
            if let user = auth.currentUser {
                self.username = user
            }
        }
    }

    private func handleLogin() {
        guard !username.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        HapticManager.impact(.medium)

        auth.setServerURL(serverURL)

        Task {
            do {
                let res = try await APIService.shared.login(username: username, password: password)
                auth.login(username: res.username, token: res.accessToken)
                HapticManager.notification(.success)
                await store.refreshAll()
            } catch {
                HapticManager.notification(.error)
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
