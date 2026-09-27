import SwiftUI
import Charts

struct SpendingTrendChart: View {

    let transactions: [Transaction]
    let budgetType: BudgetType
    let budget: Double

    @State private var range: TrendRange = .month
    @State private var scrollPosition: Date = Date()

    private var points: [TrendPoint] {
        SpendingStats.trend(of: transactions, range: range)
    }

    private var hasSpending: Bool {
        points.contains { $0.amount > 0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Spending trend")
                .font(.system(size: 20, weight: .bold, design: .rounded))

            Picker("Range", selection: $range) {
                ForEach(TrendRange.allCases) { option in
                    Text(option.title)
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)

            if hasSpending {
                chart
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
        .onAppear {
            centerOnToday()
        }
        .onChange(of: range) { _, _ in
            centerOnToday()
        }
    }

    private func centerOnToday() {
        scrollPosition = Date().addingTimeInterval(-visibleDomainLength / 2)
    }

    private var chart: some View {
        Chart {

            ForEach(points) { point in
                BarMark(
                    x: .value("Date", point.date, unit: range.axisComponent),
                    y: .value("Spent", point.amount)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(4)
            }

            if let allowance = perBucketAllowance {
                RuleMark(y: .value("Budget", allowance))
                    .lineStyle(
                        StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                    )
                    .foregroundStyle(.secondary)
                    .annotation(
                        position: .top,
                        alignment: .trailing
                    ) {
                        Text("Budget")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: range.axisComponent)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: range.axisFormat)
                    }
                }
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
        .chartScrollableAxes(range == .week ? [] : .horizontal)
        .chartXVisibleDomain(length: visibleDomainLength)
        .chartScrollPosition(x: $scrollPosition)
        .frame(height: 190)
    }

    private var visibleDomainLength: TimeInterval {
        let day: TimeInterval = 86_400
        switch range {
        case .week:
            return day * 7
        case .month:
            return day * 10
        case .year:
            return day * 30 * 6
        }
    }

    private var perBucketAllowance: Double? {

        guard budget > 0 else { return nil }

        let calendar = Calendar.current
        let now = Date()

        switch (budgetType, range) {
        case (.daily, .week), (.daily, .month):
            return budget

        case (.weekly, .week):
            return budget / 7.0

        case (.monthly, .month):
            let daysInMonth = Double(
                calendar.range(of: .day, in: .month, for: now)?.count ?? 30
            )
            return budget / daysInMonth

        case (.yearly, .year):
            return budget / 12.0

        default:
            return nil
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {

            Image(systemName: "chart.bar")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.secondary)

            Text("Nothing spent yet")
                .font(.system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                ))

            Text("Your spending will chart here")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}

extension TrendRange {

    var axisFormat: Date.FormatStyle {
        switch self {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day()
        case .year:
            return .dateTime.month(.abbreviated)
        }
    }
}

#Preview {
    SpendingTrendChart(
        transactions: Transaction.priviewTransactions,
        budgetType: .monthly,
        budget: 10000
    )
}
