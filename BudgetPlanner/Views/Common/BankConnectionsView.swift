import SwiftUI

public struct BankConnectionsView: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject var store = BudgetStore.shared

    @State private var institutions: [BankInstitution] = []
    @State private var connections: [BankConnectionOut] = []
    @State private var selectedInstitution: BankInstitution? = nil
    @State private var selectedAccountId: Int? = nil
    @State private var isLoading = false
    @State private var isSyncing = false
    @State private var statusMessage: String? = nil
    @State private var errorMessage: String? = nil
    @State private var showingConnectSheet = false

    public init() {}

    public var body: some View {
        ZStack {
            LiquidBackground()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.appEmerald.opacity(0.18))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.appEmerald)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("PSD2 Open Banking Koppelingen")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)

                                Text("Automatische sync met ASN Bank & RegioBank")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 18, strokeColor: Color.appEmerald.opacity(0.3))

                    // Active Connections
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("ACTIEVE BANKKOPPELINGEN (\(connections.count))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)

                            Spacer()

                            Button(action: { showingConnectSheet = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Bank Koppelen")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.appEmerald)
                            }
                        }
                        .padding(.horizontal, 4)

                        if connections.isEmpty {
                            VStack(spacing: 10) {
                                Text("Nog geen automatische bankkoppeling actief")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text("Koppel je ASN Bank of RegioBank rekening voor automatische nachtelijke synchronisatie, of importeer direct CSV bestanden.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .liquidGlass(cornerRadius: 16)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(connections) { conn in
                                    connectionCard(conn)
                                }
                            }
                        }
                    }

                    // Available Dutch Banks
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ONDERSTEUNDE NEDERLANDSE BANKEN")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.1)
                            .padding(.horizontal, 4)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(institutions) { bank in
                                bankGridCard(bank)
                            }
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
        .navigationTitle("Bankkoppelingen")
        .task {
            await loadData()
        }
        .sheet(isPresented: $showingConnectSheet) {
            connectModal
        }
    }

    private func connectionCard(_ conn: BankConnectionOut) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(conn.institutionName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text(conn.status)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.appEmerald)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.appEmerald.opacity(0.12))
                    .clipShape(Capsule())
            }

            if let acc = conn.linkedAccountName {
                Text("Gekoppeld aan: \(acc)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if let synced = conn.lastSyncedAt {
                Text("Laatst gesynchroniseerd: \(synced.prefix(10))")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            HStack {
                Button(action: {
                    Task {
                        isSyncing = true
                        _ = try? await APIService.shared.syncBank(connectionId: conn.id)
                        await loadData()
                        await store.refreshAll()
                        isSyncing = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Nu Syncen")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appSapphire.opacity(0.3))
                    .clipShape(Capsule())
                }

                Spacer()

                Button(action: {
                    Task {
                        try? await APIService.shared.deleteBankConnection(connectionId: conn.id)
                        await loadData()
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.appRose)
                        .padding(8)
                        .background(Circle().fill(Color.appRose.opacity(0.12)))
                }
            }
        }
        .padding(14)
        .liquidGlass(cornerRadius: 16)
    }

    private func bankGridCard(_ bank: BankInstitution) -> some View {
        Button(action: {
            selectedInstitution = bank
            showingConnectSheet = true
        }) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 34, height: 34)
                    Image(systemName: "building.columns")
                        .font(.system(size: 14))
                        .foregroundColor(.appEmerald)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(bank.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(bank.group ?? "Nederland")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(10)
            .liquidGlass(cornerRadius: 14)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var connectModal: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0B101E").ignoresSafeArea()

                VStack(spacing: 20) {
                    if let bank = selectedInstitution {
                        VStack(spacing: 8) {
                            Text("Koppel \(bank.name)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text("Je wordt veilig doorgestuurd naar de officiële bankomgeving om 90 dagen leestoegang te geven.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("KOPPELEN AAN INTERNE REKENING")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)

                        Picker("Rekening", selection: $selectedAccountId) {
                            Text("Nieuwe rekening / Automatisch").tag(nil as Int?)
                            ForEach(store.accounts) { acc in
                                Text(acc.name).tag(acc.id as Int?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                    }

                    if let msg = statusMessage {
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.appEmerald)
                            .padding(10)
                    }

                    if let err = errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.appRose)
                            .padding(10)
                    }

                    Button(action: handleConnect) {
                        HStack {
                            if isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Image(systemName: "lock.shield.fill")
                                Text("Veilig Inloggen bij Bank")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appEmerald)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isLoading)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Bank Toevoegen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleren") { showingConnectSheet = false }
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func loadData() async {
        do {
            institutions = try await APIService.shared.getBankingInstitutions()
            connections = try await APIService.shared.getBankingConnections()
        } catch {
            print("Failed to load banking data: \(error)")
        }
    }

    private func handleConnect() {
        guard let bank = selectedInstitution else { return }
        isLoading = true
        errorMessage = nil
        statusMessage = nil

        Task {
            do {
                let res = try await APIService.shared.connectBank(institutionId: bank.id, accountId: selectedAccountId)
                isLoading = false
                if let link = res.authLink, let url = URL(string: link) {
                    showingConnectSheet = false
                    openURL(url)
                } else if let msg = res.message {
                    statusMessage = msg
                }
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
