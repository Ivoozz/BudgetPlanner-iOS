import SwiftUI

public struct BudgetAlertsView: View {
    @ObservedObject var store = BudgetStore.shared

    @State private var alertStatus: AlertStatusResponse? = nil
    @State private var isSendingTest = false
    @State private var isChecking = false
    @State private var feedbackMessage: String? = nil
    @State private var errorMessage: String? = nil

    public init() {}

    public var body: some View {
        ZStack {
            LiquidBackground()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Alert Card
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.appRose.opacity(0.18))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.appRose)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Budget Bewaking & Alerts")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)

                                Text("Automatische notificaties bij overschrijding")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }

                        Divider().background(Color.white.opacity(0.08))

                        // How it works info
                        VStack(alignment: .leading, spacing: 6) {
                            alertRuleRow(icon: "exclamationmark.triangle.fill", color: .appAmber, title: "85% Waarschuwing", desc: "Melding zodra een categorie 85% van het maandbudget bereikt.")
                            alertRuleRow(icon: "nosign", color: .appRose, title: "100% Overschreden", desc: "Dringende pushnotificatie zodra een limiet overschreden wordt.")
                            alertRuleRow(icon: "calendar.badge.clock", color: .appSapphire, title: "Vaste Lasten", desc: "Herinnering 48 uur voordat een periodieke rekening vervalt.")
                        }
                    }
                    .padding(18)
                    .liquidGlass(cornerRadius: 20, strokeColor: Color.appRose.opacity(0.35))

                    // Test Action Buttons
                    VStack(spacing: 12) {
                        Button(action: handleSendTest) {
                            HStack {
                                if isSendingTest {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Stuur Testnotificatie naar Telefoon")
                                        .fontWeight(.bold)
                                }
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .liquidGlass(cornerRadius: 16, strokeColor: Color.appSapphire.opacity(0.4))
                        }
                        .disabled(isSendingTest)

                        Button(action: handleRunCheck) {
                            HStack {
                                if isChecking {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                    Text("Controleer Alle Budgetten Nu")
                                        .fontWeight(.bold)
                                }
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appEmerald)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(isChecking)
                    }

                    if let msg = feedbackMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appEmerald)
                            Text(msg)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .liquidGlass(cornerRadius: 14, strokeColor: Color.appEmerald.opacity(0.4))
                    }

                    if let err = errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.appRose)
                            .padding(12)
                            .liquidGlass(cornerRadius: 14, strokeColor: Color.appRose.opacity(0.4))
                    }

                    // Recent Triggered Alerts
                    VStack(alignment: .leading, spacing: 10) {
                        Text("RECENTE ALERTS & MELDINGEN")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                            .tracking(1.1)
                            .padding(.horizontal, 4)

                        if let alerts = alertStatus?.recentAlerts, !alerts.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(alerts) { item in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: item.threshold >= 100 ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                                            .foregroundColor(item.threshold >= 100 ? .appRose : .appAmber)
                                            .padding(.top, 2)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(item.message)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.white)

                                            if let sent = item.sentAt {
                                                Text(sent.prefix(16).replacingOccurrences(of: "T", with: " "))
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .liquidGlass(cornerRadius: 14)
                                }
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("Nog geen budgetoverschrijdingen geregistreerd.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .padding(20)
                                Spacer()
                            }
                            .liquidGlass(cornerRadius: 14)
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
        .navigationTitle("Budget Notificaties")
        .task {
            await loadStatus()
        }
    }

    private func alertRuleRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 3)
    }

    private func loadStatus() async {
        do {
            alertStatus = try await APIService.shared.getAlertsStatus()
        } catch {
            print("Failed to load alert status: \(error)")
        }
    }

    private func handleSendTest() {
        isSendingTest = true
        errorMessage = nil
        feedbackMessage = nil
        HapticManager.impact(.medium)

        Task {
            do {
                let res = try await APIService.shared.triggerTestAlert()
                isSendingTest = false
                if res.dispatched {
                    feedbackMessage = "Testnotificatie verzonden naar ntfy cluster!"
                    HapticManager.notification(.success)
                } else {
                    errorMessage = "Kon testnotificatie niet verzenden."
                }
            } catch {
                isSendingTest = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func handleRunCheck() {
        isChecking = true
        errorMessage = nil
        feedbackMessage = nil
        HapticManager.impact(.medium)

        Task {
            do {
                let res = try await APIService.shared.triggerAlertCheck()
                isChecking = false
                let count = res["triggered_count"] as? Int ?? 0
                feedbackMessage = "Budgetcontrole voltooid. \(count) melding(en) verwerkt."
                await loadStatus()
                HapticManager.notification(.success)
            } catch {
                isChecking = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
