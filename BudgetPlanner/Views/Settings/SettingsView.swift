import SwiftUI

public struct SettingsView: View {
    @ObservedObject var auth = AuthManager.shared
    @ObservedObject var store = BudgetStore.shared

    @State private var biometricsToggle: Bool = false
    @State private var showingChangePasswordSheet: Bool = false
    @State private var showingLogoutAlert: Bool = false
    @State private var showingResetAlert: Bool = false
    @State private var showingDemoAlert: Bool = false
    @State private var showingCopiedAlert: Bool = false
    @State private var systemFeedbackMessage: String? = nil
    @State private var showingFeedbackAlert: Bool = false

    public init() {}

    private var sideStoreSourceURL: String {
        "https://raw.githubusercontent.com/Ivoozz/BudgetPlanner-iOS/main/apps.json"
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        profileHeaderView

                        // Management Hub Links
                        managementHubSection

                        // Security & Biometrics
                        securitySectionView

                        // Data Tools & System
                        systemDataToolsSection

                        // SideStore Community Source
                        sideStoreSectionView

                        // Logout Button
                        logoutButtonView

                        // Credits
                        creditsFooterView

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Beheer & Meer")
            .onAppear {
                biometricsToggle = auth.isBiometricsEnabled
            }
            .sheet(isPresented: $showingChangePasswordSheet) {
                ChangePasswordSheet()
            }
            .alert("Klaar!", isPresented: $showingCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("SideStore Community Source URL is gekopieerd naar je klembord!")
            }
            .alert("Systeem Melding", isPresented: $showingFeedbackAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(systemFeedbackMessage ?? "")
            }
            .alert("Uitloggen?", isPresented: $showingLogoutAlert) {
                Button("Annuleren", role: .cancel) {}
                Button("Uitloggen", role: .destructive) {
                    auth.logout()
                }
            } message: {
                Text("Weet je zeker dat je wilt uitloggen van \(auth.serverURL)?")
            }
            .alert("Voorbeelddata Inladen?", isPresented: $showingDemoAlert) {
                Button("Annuleren", role: .cancel) {}
                Button("Inladen", role: .none) {
                    Task {
                        do {
                            let msg = try await store.seedDemoData()
                            systemFeedbackMessage = msg
                            showingFeedbackAlert = true
                        } catch {
                            systemFeedbackMessage = error.localizedDescription
                            showingFeedbackAlert = true
                        }
                    }
                }
            } message: {
                Text("Dit voegt voorbeeld transacties en rekeningen toe.")
            }
            .alert("WAARSCHUWING: Database Schonen?", isPresented: $showingResetAlert) {
                Button("Annuleren", role: .cancel) {}
                Button("Alles Wissen", role: .destructive) {
                    Task {
                        do {
                            let msg = try await store.resetDatabase()
                            systemFeedbackMessage = msg
                            showingFeedbackAlert = true
                        } catch {
                            systemFeedbackMessage = error.localizedDescription
                            showingFeedbackAlert = true
                        }
                    }
                }
            } message: {
                Text("Dit wist alle transacties, budgetten en vaste posten permanent!")
            }
        }
    }

    // MARK: - Subviews
    private var profileHeaderView: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appEmerald, Color.appSapphire],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 58))
                    .foregroundColor(.white)
            }

            Text(auth.currentUser ?? "Gebruiker")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 6) {
                Circle()
                    .fill(Color.appEmerald)
                    .frame(width: 8, height: 8)
                Text(auth.serverURL)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 20)
    }

    private var managementHubSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BEHEER & ANALYSE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.1)

            VStack(spacing: 8) {
                NavigationLink(destination: ReportsView()) {
                    hubRow(title: "Financiële Jaaranalyse", subtitle: "12-Maanden matrix & rapportages", icon: "chart.line.uptrend.xyaxis", color: .appEmerald)
                }

                NavigationLink(destination: AccountsView()) {
                    hubRow(title: "Rekeningen & Saldo", subtitle: "Beheer bank- en spaarrekeningen", icon: "creditcard.fill", color: .appSapphire)
                }

                NavigationLink(destination: CategoryManagementView()) {
                    hubRow(title: "Categorieën Beheren", subtitle: "Kleuren, iconen en categorietypes", icon: "tag.fill", color: .appAmber)
                }
            }
        }
    }

    private func hubRow(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
        }
        .padding(12)
        .liquidGlass(cornerRadius: 16)
    }

    private var securitySectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BEVEILIGING & TOEGANG")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.1)

            VStack(spacing: 10) {
                Toggle(isOn: $biometricsToggle) {
                    HStack(spacing: 10) {
                        Image(systemName: "faceid")
                            .font(.system(size: 18))
                            .foregroundColor(.appEmerald)
                        Text("Face ID Vergrendeling")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .onChange(of: biometricsToggle) { val in
                    auth.setBiometricsEnabled(val)
                }

                Divider().background(Color.white.opacity(0.08))

                Button(action: {
                    showingChangePasswordSheet = true
                }) {
                    HStack {
                        Image(systemName: "lock.rotation")
                            .foregroundColor(.appSapphire)
                        Text("Wachtwoord Wijzigen")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(14)
            .liquidGlass(cornerRadius: 16)
        }
    }

    private var systemDataToolsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATA & SYSTEEM")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.1)

            VStack(spacing: 8) {
                // Seed Demo
                Button(action: { showingDemoAlert = true }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.appAmber)
                        Text("Voorbeelddata Inladen")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(12)
                    .liquidGlass(cornerRadius: 14)
                }

                // Reset
                Button(action: { showingResetAlert = true }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.appRose)
                        Text("Alle Data Schonen & Reset")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.appRose)
                        Spacer()
                    }
                    .padding(12)
                    .liquidGlass(cornerRadius: 14, strokeColor: Color.appRose.opacity(0.3))
                }
            }
        }
    }

    private var sideStoreSectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SIDESTORE COMMUNITY SOURCE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .tracking(1.1)

            VStack(alignment: .leading, spacing: 12) {
                Text("Installeer en update Budget draadloos op je iPhone via SideStore.")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack {
                    Text(sideStoreSourceURL)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button(action: {
                        UIPasteboard.general.string = sideStoreSourceURL
                        HapticManager.notification(.success)
                        showingCopiedAlert = true
                    }) {
                        Image(systemName: "doc.on.doc.fill")
                            .foregroundColor(.appSapphire)
                    }
                }
                .padding(10)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)

                if let url = URL(string: "sidestore://source?url=\(sideStoreSourceURL)") {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "arrow.down.app.fill")
                            Text("1-Tik Toevoegen in SideStore")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.appEmerald)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding(14)
            .liquidGlass(cornerRadius: 16)
        }
    }

    private var logoutButtonView: some View {
        Button(action: { showingLogoutAlert = true }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Uitloggen")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.appRose)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .liquidGlass(cornerRadius: 14, strokeColor: Color.appRose.opacity(0.4))
        }
    }

    private var creditsFooterView: some View {
        VStack(spacing: 4) {
            Text("Budget voor iOS • v1.1.0 Liquid Glass Edition")
                .font(.caption2)
                .foregroundColor(.gray)
            Text("Ontwikkeld met meedogenloze precisie door Kapitein Syntax ⚓️")
                .font(.caption2)
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.top, 6)
    }
}
