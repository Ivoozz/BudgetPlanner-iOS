import SwiftUI

public struct MonthNavigationBar: View {
    @ObservedObject var store = BudgetStore.shared

    public init() {}

    private var monthName: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "nl_NL")
        let symbols = df.monthSymbols ?? []
        let index = store.selectedMonth - 1
        if index >= 0 && index < symbols.count {
            return symbols[index].capitalized
        }
        return "\(store.selectedMonth)"
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Month navigation picker
            HStack(spacing: 4) {
                Button(action: {
                    Task { await store.changeMonth(delta: -1) }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(7)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.appEmerald)

                    Text("\(monthName) \(String(store.selectedYear))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.07)))

                Button(action: {
                    Task { await store.changeMonth(delta: 1) }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(7)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }

                if !store.isCurrentMonth {
                    Button(action: {
                        Task { await store.resetToCurrentMonth() }
                    }) {
                        Text("Vandaag")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.appEmerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.appEmerald.opacity(0.15)))
                    }
                }
            }

            Spacer()

            // Privacy Toggle Button
            Button(action: {
                store.togglePrivacy()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: store.privacyMode ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text(store.privacyMode ? "Verborgen" : "Privacy")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(store.privacyMode ? .appAmber : .gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(store.privacyMode ? Color.appAmber.opacity(0.15) : Color.white.opacity(0.06))
                        .overlay(
                            Capsule()
                                .strokeBorder(store.privacyMode ? Color.appAmber.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }

            // Sync Refresh Button
            Button(action: {
                Task {
                    HapticManager.impact(.medium)
                    await store.refreshAll()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(store.isLoading ? .appEmerald : .white.opacity(0.8))
                    .rotationEffect(.degrees(store.isLoading ? 360 : 0))
                    .animation(store.isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: store.isLoading)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .liquidGlass(cornerRadius: 18, borderOpacity: 0.25)
    }
}
