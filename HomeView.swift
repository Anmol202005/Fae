import SwiftUI
import SwiftData

struct HomeView: View {

    @State private var selectedPeriod: PeriodSelector.Period = .month

    @Query(sort: \Transaction.timestamp, order: .reverse)
    private var transactions: [Transaction]

    @Query
    private var appData: [AppData]

    @State private var transactionDetailPath = NavigationPath()

    var body: some View {

        NavigationStack(path: $transactionDetailPath) {

            ScrollView {

                VStack {

                    HStack {

                        VStack(alignment: .leading, spacing: 8) {

                            Text(title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Text(spend)
                                .font(.system(
                                    size: 42,
                                    weight: .bold,
                                    design: .rounded
                                ))

                            if let budgetText = budgetLeftText {
                                Text(budgetText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        PeriodSelector(
                            selectedPeriod: $selectedPeriod
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28)
                    )
                    .padding(.horizontal)

                    VerticalScrollView(
                        title: "Recent Transactions",
                        transactions: Array(transactions.prefix(3))
                    ) { transaction in

                        transactionDetailPath.append(transaction)
                    }

                    SpendingTrendChart(
                        transactions: transactions,
                        budgetType: budgetType,
                        budget: budget
                    )
                    .padding(.top, 30)
                }
            }
            .navigationDestination(
                for: Transaction.self
            ) { transaction in

                TransactionDetailView(
                    transaction: transaction
                )
            }
        }
    }

    private var title: String {

        switch selectedPeriod {

        case .today:
            return Constants.todaysSpendString

        case .week:
            return Constants.weeklySpendString

        case .month:
            return Constants.monthlySpendString

        case .year:
            return Constants.yearlySpendString
        }
    }

    private var currentExpense: Double {

        guard let data = appData.first else {
            return 0
        }

        switch selectedPeriod {

        case .today:
            return data.dailyExpense

        case .week:
            return data.weeklyExpense

        case .month:
            return data.monthlyExpense

        case .year:
            return data.yearlyExpense
        }
    }

    private var spend: String {
        formatCurrency(currentExpense)
    }

    private var budgetType: BudgetType {
        appData.first?.budgetType ?? .none
    }

    private var budget: Double {
        appData.first?.budget ?? 0
    }

    private var budgetLeftText: String? {

        guard let data = appData.first else {
            return nil
        }

        let budgetApplies: Bool

        switch selectedPeriod {

        case .today:
            budgetApplies = data.budgetType == .daily

        case .week:
            budgetApplies = data.budgetType == .weekly

        case .month:
            budgetApplies = data.budgetType == .monthly

        case .year:
            budgetApplies = data.budgetType == .yearly
        }

        guard budgetApplies else {
            return nil
        }

        let remaining = max(data.budget - currentExpense, 0)

        return "Budget left \(formatCurrency(remaining))"
    }

     func formatCurrency(_ value: Double) -> String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? "₹0"
    }
}

#Preview {
    HomeView()
}
