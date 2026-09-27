import SwiftUI
import Charts

struct WeekdaySpendingChart: View {

    let transactions: [Transaction]
    let interval: DateInterval
    let rangeTitle: String

    private struct DayTotal: Identifiable {

        let label: String
        let amount: Double

        var id: String { label }
    }

    private static let weekOrder = [2, 3, 4, 5, 6, 7, 1]
    private static let weekNames = [
        "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ]

    private var totals: [DayTotal] {

        let calendar = Calendar.current
        var bucket: [Int: Double] = [:]

        for transaction in transactions {

            let date = transaction.effectiveDate
            guard interval.contains(date) else { continue }

            let weekday = calendar.component(.weekday, from: date)
            bucket[weekday, default: 0] += Double(transaction.amount)
        }

        return zip(Self.weekOrder, Self.weekNames).map { weekday, name in
            DayTotal(label: name, amount: bucket[weekday] ?? 0)
        }
    }

    private var heaviest: DayTotal? {
        totals
            .filter { $0.amount > 0 }
            .max { $0.amount < $1.amount }
    }

    private var hasSpending: Bool {
        totals.contains { $0.amount > 0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .firstTextBaseline) {

                Text("By weekday")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Spacer()

                Text(rangeTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if hasSpending {
                chart
                heaviestText
            } else {
                emptyState
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .padding(.horizontal)
    }

    private var chart: some View {
        Chart(totals) { day in

            BarMark(
                x: .value("Day", day.label),
                y: .value("Spent", day.amount)
            )
            .foregroundStyle(
                day.label == heaviest?.label
                ? Color.orange
                : Color.blue.opacity(0.55)
            )
            .cornerRadius(5)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(Currency.compactString(from: amount))
                    }
                }
            }
        }
        .frame(height: 170)
    }

    @ViewBuilder
    private var heaviestText: some View {

        if let heaviest {

            Text(
                "\(heaviest.label) is your heaviest day at \(Currency.string(from: heaviest.amount))"
            )
            .font(.system(
                size: 13,
                weight: .semibold,
                design: .rounded
            ))
            .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {

        VStack(spacing: 10) {

            Image(systemName: "calendar")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.secondary)

            Text("No spending yet")
                .font(.system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                ))

            Text("Your weekday pattern will appear here")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}

#Preview {
    WeekdaySpendingChart(
        transactions: Transaction.priviewTransactions,
        interval: BudgetType.monthly.interval(containing: Date()),
        rangeTitle: "This month"
    )
}
