import SwiftUI

public struct AccountCarouselView: View {
    public let accounts: [Account]
    public var onSelectAccount: ((Account) -> Void)? = nil

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("REKENINGEN & SALDO'S")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .tracking(1.1)

                Spacer()

                NavigationLink(destination: AccountsView()) {
                    Text("Alles bekijken")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.appSapphire)
                }
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(accounts) { acc in
                        Button(action: {
                            onSelectAccount?(acc)
                        }) {
                            AccountCard(account: acc)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }
}

public struct AccountCard: View {
    public let account: Account

    private var themeColor: Color {
        Color(hex: account.color)
    }

    private var sfSymbol: String {
        SFSymbolPicker.mapIcon(account.icon)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.2))
                        .frame(width: 34, height: 34)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeColor)
                }

                Spacer()

                Text(account.type.displayName)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(themeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(themeColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)

                Text(CurrencyFormatter.format(account.balance))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .frame(width: 175, height: 125)
        .liquidGlass(cornerRadius: 18, strokeColor: themeColor.opacity(0.35))
    }
}
