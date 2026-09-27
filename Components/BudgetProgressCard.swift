import SwiftUI

struct BudgetProgressCard: View {

    let spent: Double
    let budget: Double
    let periodName: String

    private var progress: Double {
        guard budget > 0 else {
            return 0
        }
        return spent / budget
    }

    private var isOverBudget: Bool {
        budget > 0 && spent > budget
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            HStack(alignment: .firstTextBaseline) {

                VStack(alignment: .leading, spacing: 6) {

                    Text("\(periodName) budget")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(Currency.string(from: spent))
                        .font(.system(
                            size: 34,
                            weight: .bold,
                            design: .rounded
                        ))
                }

                Spacer()

                Text("of \(Currency.string(from: budget))")
                    .font(.system(
                        size: 15,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(.secondary)
            }

            bar

            HStack {

                Text(statusText)
                    .font(.system(
                        size: 14,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(isOverBudget ? .red : .secondary)

                Spacer()

                Text("\(Int((progress * 100).rounded()))% used")
                    .font(.system(
                        size: 14,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .padding(.horizontal)
    }

    private var statusText: String {
        if isOverBudget {
            return "Over by \(Currency.string(from: spent - budget))"
        }
        return "\(Currency.string(from: max(budget - spent, 0))) left"
    }

    private var bar: some View {
        GeometryReader { geometry in

            ZStack(alignment: .leading) {

                Capsule()
                    .fill(.secondary.opacity(0.2))

                Capsule()
                    .fill(isOverBudget ? Color.red : Color.blue)
                    .frame(
                        width: geometry.size.width * min(progress, 1)
                    )
            }
        }
        .frame(height: 12)
    }
}

#Preview {
    VStack(spacing: 20) {
        BudgetProgressCard(
            spent: 4200,
            budget: 10000,
            periodName: "Monthly"
        )

        BudgetProgressCard(
            spent: 11200,
            budget: 10000,
            periodName: "Monthly"
        )
    }
}
