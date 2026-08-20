import SwiftUI

public struct SettingsView: View {
    @ObservedObject var auth = AuthManager.shared
    @ObservedObject var store = BudgetStore.shared

    @State private var biometricsToggle: Bool = false
    @State private var showingLogoutAlert: Bool = false
    @State private var showingCopiedAlert: Bool = false

    public init() {}

    private var sideStoreSourceURL: String {
        "https://raw.githubusercontent.com/Ivoozz/BudgetPlanner-iOS/main/apps.json"
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        // Profile & Server Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appEmerald, Color.appSapphire],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 72, height: 72)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(.white)
                            }

                            Text(auth.currentUser ?? "Gebruiker")
                                .font(.system(size: 20, weight: .bold))
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
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .liquidGlass(cornerRadius: 22)

                        // Sync Status & Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SYNCHRONISATIE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)

                            VStack(spacing: 12) {
                                HStack {
                                    Text("Status")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("Verbonden met Cloud")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.appEmerald)
                                }

                                if let lastSync = store.lastSyncDate {
                                    HStack {
                                        Text("Laatste sync")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(lastSync, style: .time)
                                            .foregroundColor(.white)
                                    }
                                }

                                Divider().background(Color.white.opacity(0.1))

                                Button(action: {
                                    Task {
                                        HapticManager.impact(.medium)
                                        await store.refreshAll()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Nu Handmatig Synchroniseren")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.appSapphire)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding(16)
                            .liquidGlass(cornerRadius: 18)
                        }

                        // Beveiliging
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BEVEILIGING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)

                            VStack(spacing: 12) {
                                Toggle(isOn: $biometricsToggle) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "faceid")
                                            .font(.system(size: 18))
                                            .foregroundColor(.appEmerald)
                                        Text("Face ID Vergrendeling")
                                            .foregroundColor(.white)
                                    }
                                }
                                .onChange(of: biometricsToggle) { val in
                                    auth.setBiometricsEnabled(val)
                                }
                            }
                            .padding(16)
                            .liquidGlass(cornerRadius: 18)
                        }

                        // SideStore & Distributie
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SIDESTORE COMMUNITY SOURCE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Installeer en update BudgetPlanner draadloos direct op je iPhone via SideStore.")
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
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.appEmerald)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                }
                            }
                            .padding(16)
                            .liquidGlass(cornerRadius: 18)
                        }

                        // Uitloggen
                        Button(action: { showingLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Uitloggen")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.appRose)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .liquidGlass(cornerRadius: 16, strokeColor: Color.appRose.opacity(0.4))
                        }

                        // App Credits & Build Info
                        VStack(spacing: 4) {
                            Text("BudgetPlanner voor iOS • v1.0.0")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text("Ontwikkeld met meedogenloze precisie door Kapitein Syntax ⚓️")
                                .font(.caption2)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.top, 10)

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Instellingen")
            .onAppear {
                biometricsToggle = auth.isBiometricsEnabled
            }
            .alert("Klaar!", isPresented: $showingCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("SideStore Community Source URL is gekopieerd naar je klembord!")
            }
            .alert("Uitloggen?", isPresented: $showingLogoutAlert) {
                Button("Annuleren", role: .cancel) {}
                Button("Uitloggen", role: .destructive) {
                    auth.logout()
                }
            } message: {
                Text("Weet je zeker dat je wilt uitloggen van \(auth.serverURL)?")
            }
        }
    }
}
