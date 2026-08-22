import SwiftUI
import UniformTypeIdentifiers

public struct ImportCsvSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = BudgetStore.shared

    @State private var selectedAccountId: Int? = nil
    @State private var showingFilePicker = false
    @State private var selectedFileName: String? = nil
    @State private var selectedFileData: Data? = nil
    @State private var isUploading = false
    @State private var importResult: CSVImportResponse? = nil
    @State private var errorMessage: String? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                LiquidBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Banner
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.appEmerald.opacity(0.18))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "square.and.arrow.down.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.appEmerald)
                            }

                            Text("Banktransacties Importeren")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            Text("Ondersteunt ASN Bank, RegioBank, SNS, ING, Rabobank, ABN AMRO en bunq CSV bestanden.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                        .padding(.top, 10)

                        // Target Account Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KOPPELEN AAN REKENING")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1.1)

                            Picker("Rekening", selection: $selectedAccountId) {
                                Text("Automatisch / Geen specifieke rekening").tag(nil as Int?)
                                ForEach(store.accounts) { acc in
                                    Text(acc.name).tag(acc.id as Int?)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 4)

                        // File Selector Card
                        Button(action: {
                            showingFilePicker = true
                            HapticManager.impact(.light)
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: selectedFileData != nil ? "doc.text.fill" : "arrow.up.doc.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(selectedFileData != nil ? .appEmerald : .appSapphire)

                                if let name = selectedFileName {
                                    Text(name)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Tik om een ander CSV bestand te kiezen")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Selecteer CSV van je iPhone")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Geëxporteerd vanuit ASN Online Bankieren of de app")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(
                                        selectedFileData != nil ? Color.appEmerald : Color.appSapphire.opacity(0.4),
                                        style: StrokeStyle(lineWidth: 1.5, dash: [6])
                                    )
                                    .background(Color.white.opacity(0.03))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Feedback Messages
                        if let res = importResult {
                            VStack(spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.appEmerald)
                                    Text("\(res.count) transacties succesvol geïmporteerd!")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Text("Transacties zijn direct gecategoriseerd en gekoppeld.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .liquidGlass(cornerRadius: 16, strokeColor: Color.appEmerald.opacity(0.4))
                        }

                        if let err = errorMessage {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.appRose)
                                .padding(12)
                                .liquidGlass(cornerRadius: 14, strokeColor: Color.appRose.opacity(0.4))
                        }

                        // Submit Button
                        Button(action: handleUpload) {
                            HStack {
                                if isUploading {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Image(systemName: "arrow.up.circle.fill")
                                    Text("Nu Importeren")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color.appEmerald, Color(hex: "#059669")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .disabled(selectedFileData == nil || isUploading)
                        .opacity(selectedFileData != nil && !isUploading ? 1.0 : 0.5)

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Bank CSV Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sluiten") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .plainText, .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        guard url.startAccessingSecurityScopedResource() else { return }
                        defer { url.stopAccessingSecurityScopedResource() }
                        if let data = try? Data(contentsOf: url) {
                            selectedFileData = data
                            selectedFileName = url.lastPathComponent
                            importResult = nil
                            errorMessage = nil
                        }
                    }
                case .failure(let err):
                    errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func handleUpload() {
        guard let data = selectedFileData, let name = selectedFileName else { return }
        isUploading = true
        errorMessage = nil
        HapticManager.impact(.medium)

        Task {
            do {
                let res = try await APIService.shared.importCSV(fileData: data, fileName: name, accountId: selectedAccountId, apply: true)
                importResult = res
                isUploading = false
                HapticManager.notification(.success)
                await store.refreshAll()
            } catch {
                errorMessage = error.localizedDescription
                isUploading = false
                HapticManager.notification(.error)
            }
        }
    }
}
