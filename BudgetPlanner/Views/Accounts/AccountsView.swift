import SwiftUI

public struct AccountsView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var showingAddAccount: Bool = false
    @State private var showingTransfer: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        // Month & Privacy Bar
                        MonthNavigationBar()

                        // Total Balance Hero Card
                        VStack(spacing: 12) {
                            Text("TOTAAL VERMOGEN OP REKENINGEN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)

                            Text(CurrencyFormatter.format(store.totalBalance, privacy: store.privacyMode))
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)

                            HStack(spacing: 12) {
                                Button(action: { showingTransfer = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.left.arrow.right")
                                        Text("Overboeken")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.appSapphire.opacity(0.3))
                                    .clipShape(Capsule())
                                }

                                Button(action: { showingAddAccount = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                        Text("Nieuwe rekening")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .liquidGlass(cornerRadius: 22, strokeColor: Color.appSapphire.opacity(0.35))

                        // Accounts List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ALLE REKENINGEN (\(store.accounts.count))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)
                                .padding(.horizontal, 4)

                            VStack(spacing: 10) {
                                ForEach(store.accounts) { acc in
                                    let color = Color(hex: acc.color)
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(color.opacity(0.2))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: SFSymbolPicker.mapIcon(acc.icon))
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(color)
                                        }

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(acc.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)

                                            Text(acc.type.displayName)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        Text(CurrencyFormatter.format(acc.balance, privacy: store.privacyMode))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    .padding(14)
                                    .liquidGlass(cornerRadius: 18, strokeColor: color.opacity(0.25))
                                }
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await store.refreshAll()
                }
            }
            .navigationTitle("Rekeningen")
            .sheet(isPresented: $showingAddAccount) {
                AddAccountSheet()
            }
            .sheet(isPresented: $showingTransfer) {
                TransferSheet()
            }
        }
    }
}
