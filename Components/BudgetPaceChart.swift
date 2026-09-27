import SwiftUI
import Charts

struct BudgetPaceChart: View {

    let transactions: [Transaction]
    let budgetType: BudgetType
    let budget: Double

    private struct ChartPoint: Identifiable {

        let date: Date
        let amount: Double

        var id: Date { date }
    }

    private var interval: DateInterval {
        budgetType.interval(containing: Date())
    }

    private var daysInPeriod: Double {
        max(budgetType.daysInPeriod(containing: Date()), 1)
    }

    private var perDay: Double {
        budget / daysInPeriod
    }

    private var spentPoints: [ChartPoint] {

        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        var daily: [Date: Double] = [:]

        for transaction in transactions {
            let date = transaction.effectiveDate
            guard interval.contains(date), date <= now else { continue }

            daily[calendar.startOfDay(for: date), default: 0] += Double(
                transaction.amount
            )
        }

        var result: [ChartPoint] = []
        var running = 0.0
        var day = calendar.startOfDay(for: interval.start)

        while day <= today && day < interval.end {

            running += daily[day] ?? 0
            result.append(ChartPoint(date: day, amount: running))

            guard let next = calendar.date(
                byAdding: .day,
                value: 1,
                to: day
            ) else {
                break
            }

            day = next
        }

        return result
    }

    private var pacePoints: [ChartPoint] {

        let calendar = Calendar.current

        var result: [ChartPoint] = []
        var index = 0.0
        var day = calendar.startOfDay(for: interval.start)

        while day < interval.end {

            index += 1
            result.append(
                ChartPoint(date: day, amount: perDay * index)
            )

            guard let next = calendar.date(
                byAdding: .day,
                value: 1,
                to: day
            ) else {
                break
            }

            day = next
        }

        return result
    }

    private var elapsedDays: Double {

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: interval.start)
        let today = calendar.startOfDay(for: Date())

        let elapsed = calendar.dateComponents(
            [.day],
            from: start,
            to: today
        ).day ?? 0

        return Double(elapsed) + 1
    }

    private var spentSoFar: Double {
        SpendingStats.total(
            of: transactions,
            in: DateInterval(start: interval.start, end: Date())
        )
    }

    private var difference: Double {
        spentSoFar - perDay * elapsedDays
    }

    private var isOverPace: Bool {
        difference > 0
    }

    private var paceText: String {

        guard abs(difference) >= 1 else {
            return "Right on pace"
        }

        let amount = Currency.string(from: abs(difference))

        return isOverPace
            ? "\(amount) over pace"
            : "\(amount) under pace"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .firstTextBaseline) {

                Text("Budget pace")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Spacer()

                Text(paceText)
                    .font(.caption)
                    .foregroundStyle(isOverPace ? .red : .green)
            }

            chart
            legend
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .padding(.horizontal)
    }

    private var chart: some View {
        Chart {

            ForEach(spentPoints) { point in

                AreaMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Spent", point.amount)
                )
                .foregroundStyle(Color.blue.opacity(0.15).gradient)
                .interpolationMethod(.monotone)

                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Spent", point.amount)
                )
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.monotone)
            }

            ForEach(pacePoints) { point in

                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Budget pace", point.amount),
                    series: .value("Series", "pace")
                )
                .foregroundStyle(.secondary)
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                .interpolationMethod(.linear)
            }
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
        .frame(height: 190)
    }

    private var legend: some View {
        HStack(spacing: 18) {

            legendItem(title: "Spent", tint: .blue)

            legendItem(title: "Budget pace", tint: .secondary)
        }
    }

    private func legendItem(title: String, tint: Color) -> some View {

        HStack(spacing: 6) {

            Capsule()
                .fill(tint)
                .frame(width: 16, height: 4)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            BudgetPaceChart(
                transactions: Transaction.priviewTransactions,
                budgetType: .monthly,
                budget: 40000
            )

            BudgetPaceChart(
                transactions: Transaction.priviewTransactions,
                budgetType: .daily,
                budget: 800
            )
        }
    }
}
