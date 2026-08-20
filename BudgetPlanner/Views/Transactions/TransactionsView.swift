import SwiftUI

public struct TransactionsView: View {
    @ObservedObject var store = BudgetStore.shared

    @State private var searchText: String = ""
    @State private var selectedType: String = "all"
    @State private var selectedCategoryId: Int? = nil
    @State private var selectedAccountId: Int? = nil
    @State private var showingAddSheet: Bool = false
    @State private var showingExportShareSheet: Bool = false
    @State private var exportCSVURL: URL? = nil

    public init() {}

    private var transactionTypes: [(id: String, name: String)] {
        [
            ("all", "Alles"),
            ("variable_expense", "Variabel"),
            ("fixed_expense", "Vaste Last"),
            ("one_time_expense", "Eenmalig"),
            ("income", "Salaris/Inkomen"),
            ("one_time_income", "Extra Inkomen"),
            ("savings", "Sparen"),
            ("transfer", "Overboeking")
        ]
    }

    private var filteredTransactions: [Transaction] {
        store.recentTransactions.filter { tx in
            // Search filter
            if !searchText.isEmpty {
                let s = searchText.lowercased()
                let payeeMatch = tx.payee.lowercased().contains(s)
                let descMatch = tx.description.lowercased().contains(s)
                let catMatch = tx.category?.name.lowercased().contains(s) ?? false
                if !payeeMatch && !descMatch && !catMatch {
                    return false
                }
            }

            // Type filter
            if selectedType != "all" && tx.type.rawValue != selectedType {
                return false
            }

            // Category filter
            if let catId = selectedCategoryId, tx.categoryId != catId {
                return false
            }

            // Account filter
            if let accId = selectedAccountId, tx.accountId != accId {
                return false
            }

            return true
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        // Month & Privacy Bar
                        MonthNavigationBar()

                        // Search & Filters Header
                        searchAndFiltersHeader

                        // Category & Account Picker Row
                        dropdownFilterRow

                        // Transactions List
                        if filteredTransactions.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(filteredTransactions) { tx in
                                    TransactionRowView(transaction: tx)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                Task { await store.deleteTransaction(id: tx.id) }
                                            } label: {
                                                Label("Verwijderen", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }

                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
                .refreshable {
                    await store.refreshAll()
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddSheet = true
                            HapticManager.impact(.medium)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appEmerald, Color(hex: "#059669")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color.appEmerald.opacity(0.4), radius: 10, x: 0, y: 5)

                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle("Transacties")
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionSheet(defaultType: .variableExpense)
            }
        }
    }

    // MARK: - Subviews
    private var searchAndFiltersHeader: some View {
        VStack(spacing: 10) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Zoek op omschrijving of partij...", text: $searchText)
                    .foregroundColor(.white)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)

            // Type Filter Pills ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(transactionTypes, id: \.id) { item in
                        let isSelected = selectedType == item.id
                        Button(action: {
                            HapticManager.selection()
                            selectedType = item.id
                        }) {
                            Text(item.name)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.appEmerald.opacity(0.3) : Color.white.opacity(0.05))
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(isSelected ? Color.appEmerald.opacity(0.6) : Color.clear, lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding(14)
        .liquidGlass(cornerRadius: 18)
    }

    private var dropdownFilterRow: some View {
        HStack(spacing: 8) {
            // Category Filter
            Menu {
                Button("Alle Categorieën") { selectedCategoryId = nil }
                ForEach(store.categories) { cat in
                    Button(cat.name) { selectedCategoryId = cat.id }
                }
            } label: {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 10))
                    Text(selectedCategoryId != nil ? (store.categories.first { $0.id == selectedCategoryId }?.name ?? "Categorie") : "Categorieën")
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                }
                .foregroundColor(selectedCategoryId != nil ? .appEmerald : .gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
            }

            // Account Filter
            Menu {
                Button("Alle Rekeningen") { selectedAccountId = nil }
                ForEach(store.accounts) { acc in
                    Button(acc.name) { selectedAccountId = acc.id }
                }
            } label: {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 10))
                    Text(selectedAccountId != nil ? (store.accounts.first { $0.id == selectedAccountId }?.name ?? "Rekening") : "Rekeningen")
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9))
                }
                .foregroundColor(selectedAccountId != nil ? .appSapphire : .gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
            }

            Spacer()

            Text("\(filteredTransactions.count) items")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 4)
    }

    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "receipt")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.4))
            Text("Geen transacties gevonden")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Text("Pas je filters aan of voeg een transactie toe.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 18)
    }
}
