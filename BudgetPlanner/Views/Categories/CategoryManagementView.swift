import SwiftUI

public struct CategoryManagementView: View {
    @ObservedObject var store = BudgetStore.shared
    @State private var showingAddSheet: Bool = false
    @State private var editingCategory: Category? = nil

    public init() {}

    public var body: some View {
        ZStack {
            LiquidBackground()

            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("CATEGORIEËN (\(store.categories.count))")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.1)

                        Spacer()

                        Button(action: {
                            editingCategory = nil
                            showingAddSheet = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Nieuwe Categorie")
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.appEmerald)
                        }
                    }
                    .padding(.horizontal, 4)

                    LazyVStack(spacing: 8) {
                        ForEach(store.categories) { cat in
                            categoryRow(cat)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
        .navigationTitle("Categorieën Beheren")
        .sheet(isPresented: $showingAddSheet) {
            AddCategorySheet(editingCategory: editingCategory)
        }
    }

    private func categoryRow(_ cat: Category) -> some View {
        HStack(spacing: 12) {
            CategoryIconView(icon: cat.icon, colorHex: cat.color, size: 38, iconSize: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(cat.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text(cat.type == "expense" ? "Uitgave" : (cat.type == "income" ? "Inkomen" : cat.type))
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                editingCategory = cat
                showingAddSheet = true
            }) {
                Image(systemName: "pencil")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.06)))
            }

            Button(action: {
                Task {
                    HapticManager.notification(.warning)
                    await store.deleteCategory(id: cat.id)
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundColor(.appRose)
                    .padding(8)
                    .background(Circle().fill(Color.appRose.opacity(0.12)))
            }
        }
        .padding(12)
        .liquidGlass(cornerRadius: 16)
    }
}

public struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    public var editingCategory: Category?

    @State private var name: String = ""
    @State private var type: String = "expense"
    @State private var selectedColor: String = "#10B981"
    @State private var selectedIcon: String = "tag.fill"
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil

    private let colors = [
        "#10B981", "#3B82F6", "#8B5CF6", "#EC4899", "#F59E0B",
        "#EF4444", "#06B6D4", "#14B8A6", "#84CC16", "#6366F1"
    ]

    private let icons = [
        "tag.fill", "cart.fill", "house.fill", "car.fill", "bolt.fill",
        "cross.case.fill", "airplane", "heart.fill", "film.fill", "fork.knife",
        "bag.fill", "gift.fill", "tram.fill", "cup.and.saucer.fill", "dollarsign.circle.fill"
    ]

    public init(editingCategory: Category? = nil) {
        self.editingCategory = editingCategory
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0B101E").ignoresSafeArea()

                Form {
                    Section("CATEGORIE GEGEVENS") {
                        TextField("Categorienaam (bijv. Boodschappen)", text: $name)
                            .foregroundColor(.white)

                        Picker("Type", selection: $type) {
                            Text("Uitgaven").tag("expense")
                            Text("Inkomsten").tag("income")
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    Section("KLEUR") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(colors, id: \.self) { hex in
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == hex ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = hex
                                            HapticManager.selection()
                                        }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    Section("ICOON") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(icons, id: \.self) { ico in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedIcon == ico ? Color(hex: selectedColor).opacity(0.3) : Color.white.opacity(0.06))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: ico)
                                            .foregroundColor(selectedIcon == ico ? Color(hex: selectedColor) : .gray)
                                    }
                                    .onTapGesture {
                                        selectedIcon = ico
                                        HapticManager.selection()
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.06))

                    if let err = errorMessage {
                        Section {
                            Text(err).font(.caption).foregroundColor(.appRose)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(editingCategory != nil ? "Categorie Bewerken" : "Nieuwe Categorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleren") { dismiss() }
                        .foregroundColor(.gray)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(editingCategory != nil ? "Bijwerken" : "Toevoegen") {
                        save()
                    }
                    .font(.headline)
                    .foregroundColor(.appEmerald)
                    .disabled(isSaving || name.isEmpty)
                }
            }
            .onAppear {
                if let cat = editingCategory {
                    name = cat.name
                    type = cat.type
                    selectedColor = cat.color
                    selectedIcon = cat.icon
                }
            }
        }
    }

    private func save() {
        isSaving = true
        errorMessage = nil

        Task {
            do {
                if let cat = editingCategory {
                    try await store.updateCategory(id: cat.id, name: name, type: type, icon: selectedIcon, color: selectedColor)
                } else {
                    try await store.addCategory(name: name, type: type, icon: selectedIcon, color: selectedColor)
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}
