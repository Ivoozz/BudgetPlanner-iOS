import SwiftUI

public struct TransactionsView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var searchText = ""
    @State private var selectedFilterType: String? = nil
    @State private var showingAddSheet = false

    private var filteredTransactions: [Transaction] {
        store.recentTransactions.filter { tx in
            if let f = selectedFilterType, !f.isEmpty {
                if tx.type.rawValue != f { return false }
            }
            if !searchText.isEmpty {
                let s = searchText.lowercased()
                let payeeMatch = tx.payee.lowercased().contains(s)
                let descMatch = tx.description.lowercased().contains(s)
                let catMatch = tx.category?.name.lowercased().contains(s) ?? false
                let notesMatch = tx.notes.lowercased().contains(s)
                return payeeMatch || descMatch || catMatch || notesMatch
            }
            return true
        }
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#090D16").ignoresSafeArea()

                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Zoek transactie, categorie of winkel...", text: $searchText)
                            .foregroundColor(.white)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)

                    // Type Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterPill(title: "Alles", value: nil)
                            filterPill(title: "Variabel", value: "variable_expense")
                            filterPill(title: "Vaste Lasten", value: "fixed_expense")
                            filterPill(title: "Inkomsten", value: "income")
                            filterPill(title: "Eenmalig", value: "one_time_expense")
                            filterPill(title: "Sparen", value: "savings")
                        }
                        .padding(.horizontal, 16)
                    }

                    // Transactions List
                    if filteredTransactions.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Geen transacties gevonden")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredTransactions) { tx in
                                TransactionRowView(transaction: tx)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            Task { await store.deleteTransaction(id: tx.id) }
                                        } label: {
                                            Label("Verwijder", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await store.refreshAll()
                        }
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Transacties")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.appEmerald)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionSheet()
            }
        }
    }

    private func filterPill(title: String, value: String?) -> some View {
        let isSelected = (selectedFilterType == value)
        return Button(action: {
            selectedFilterType = value
            HapticManager.selection()
        }) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.appEmerald : Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
    }
}
