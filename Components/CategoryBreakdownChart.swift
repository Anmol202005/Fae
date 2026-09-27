import SwiftUI
import Charts

struct CategoryBreakdownChart: View {

    let transactions: [Transaction]
    let interval: DateInterval
    let rangeTitle: String

    private var totals: [CategoryTotal] {
        SpendingStats.categoryTotals(of: transactions, in: interval)
    }

    private var total: Double {
        totals.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .firstTextBaseline) {

                Text("Where it went")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Spacer()

                Text(rangeTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if totals.isEmpty {
                emptyState
            } else {
                donut
                legend
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .padding(.horizontal)
    }

    private var donut: some View {
        Chart(totals) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.62),
                angularInset: 2
            )
            .foregroundStyle(CategoryPalette.color(for: item.category))
            .cornerRadius(6)
        }
        .frame(height: 200)
        .overlay {
            VStack(spacing: 2) {

                Text("Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(Currency.string(from: total))
                    .font(.system(
                        size: 18,
                        weight: .bold,
                        design: .rounded
                    ))
            }
        }
    }

    private var legend: some View {
        VStack(spacing: 12) {

            ForEach(totals) { item in

                HStack(spacing: 10) {

                    Circle()
                        .fill(CategoryPalette.color(for: item.category))
                        .frame(width: 10, height: 10)

                    Text(item.category)
                        .font(.system(
                            size: 15,
                            weight: .medium,
                            design: .rounded
                        ))

                    Spacer()

                    Text(Currency.string(from: item.amount))
                        .font(.system(
                            size: 15,
                            weight: .semibold,
                            design: .rounded
                        ))

                    Text(share(of: item.amount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 42, alignment: .trailing)
                }
            }
        }
    }

    private func share(of amount: Double) -> String {
        guard total > 0 else {
            return "0%"
        }
        return "\(Int((amount / total * 100).rounded()))%"
    }

    private var emptyState: some View {
        VStack(spacing: 10) {

            Image(systemName: "chart.pie")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.secondary)

            Text("No categories yet")
                .font(.system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                ))

            Text("Categorised spending will appear here")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}

enum CategoryPalette {

    private static let colors: [Color] = [
        .blue,
        .orange,
        .green,
        .purple,
        .pink,
        .teal,
        .indigo,
        .yellow
    ]

    private static let knownCategories = Constants.spendingCategories

    static func color(for category: String) -> Color {

        if let index = knownCategories.firstIndex(of: category) {
            return colors[index % colors.count]
        }

        let hash = category.unicodeScalars.reduce(0) { result, scalar in
            (result &* 31) &+ Int(scalar.value)
        }

        return colors[abs(hash) % colors.count]
    }
}

#Preview {
    CategoryBreakdownChart(
        transactions: Transaction.priviewTransactions,
        interval: BudgetType.monthly.interval(containing: Date()),
        rangeTitle: "This month"
    )
}
