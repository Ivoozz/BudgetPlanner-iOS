import SwiftUI

public struct SavingsGoalCard: View {
    public let goal: SavingsGoal
    @ObservedObject var store = BudgetStore.shared
    @State private var showingContributeSheet: Bool = false

    public init(goal: SavingsGoal) {
        self.goal = goal
    }

    private var themeColor: Color {
        Color(hex: goal.color)
    }

    public var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                // Progress Ring
                ZStack {
                    ProgressRing(
                        progress: goal.progress,
                        lineWidth: 6,
                        tintColor: themeColor
                    )
                    .frame(width: 52, height: 52)

                    Text(store.privacyMode ? "••%" : "\(String(format: "%.0f", goal.progress * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Text(CurrencyFormatter.format(goal.currentAmount, privacy: store.privacyMode))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(themeColor)

                        Text("van \(CurrencyFormatter.format(goal.targetAmount, privacy: store.privacyMode))")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }

                    if let targetDate = goal.targetDate, !targetDate.isEmpty {
                        Text("Doeldatum: \(targetDate)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Contribute button
                Button(action: {
                    showingContributeSheet = true
                    HapticManager.impact(.medium)
                }) {
                    Text("Bijstorten")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(themeColor)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 18, strokeColor: themeColor.opacity(0.3))
        .sheet(isPresented: $showingContributeSheet) {
            ContributeSavingsSheet(goal: goal)
        }
    }
}
