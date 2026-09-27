import SwiftUI
import SwiftData

struct BudgetView: View {

    @Query
    private var appData: [AppData]

    @Query(sort: \Transaction.timestamp, order: .reverse)
    private var transactions: [Transaction]

    var body: some View {
        ScrollView {

            VStack(spacing: 20) {

                Text("Budget")
                    .font(.system(size: 22, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical)

                BudgetEditorCard()

                if budgetType != .none {
                    BudgetProgressCard(
                        spent: periodSpend,
                        budget: budget,
                        periodName: budgetType.displayName
                    )
                }

                if budgetType != .none && budget > 0 {
                    BudgetPaceChart(
                        transactions: transactions,
                        budgetType: budgetType,
                        budget: budget
                    )
                }

                WeekdaySpendingChart(
                    transactions: transactions,
                    interval: breakdownInterval,
                    rangeTitle: breakdownRangeTitle
                )

                CategoryBreakdownChart(
                    transactions: transactions,
                    interval: breakdownInterval,
                    rangeTitle: breakdownRangeTitle
                )
            }
            .padding(.bottom)
        }
    }

    private var budgetType: BudgetType {
        appData.first?.budgetType ?? .none
    }

    private var budget: Double {
        appData.first?.budget ?? 0
    }

    private var periodSpend: Double {
        SpendingStats.total(
            of: transactions,
            in: budgetType.interval(containing: Date())
        )
    }

    private var breakdownInterval: DateInterval {
        let period: BudgetType = budgetType == .none
            ? .monthly
            : budgetType

        return period.interval(containing: Date())
    }

    private var breakdownRangeTitle: String {
        switch budgetType {
        case .daily:
            return "Today"
        case .weekly:
            return "This week"
        case .monthly:
            return "This month"
        case .yearly:
            return "This year"
        case .none:
            return "This month"
        }
    }
}

#Preview {
    BudgetView()
}
