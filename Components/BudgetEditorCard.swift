import SwiftUI
import SwiftData

struct BudgetEditorCard: View {

    @Environment(\.modelContext) private var modelContext

    @Query
    private var appData: [AppData]

    @State private var isEditing = false
    @State private var period: BudgetType = .monthly
    @State private var amount = 0

    private var budgetType: BudgetType {
        appData.first?.budgetType ?? .none
    }

    private var budget: Double {
        appData.first?.budget ?? 0
    }

    private var hasBudget: Bool {
        budgetType != .none && budget > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            if isEditing || !hasBudget {
                editor
            } else {
                summary
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .padding(.horizontal)
        .keyboardDoneButton()
        .task(id: budget) {
            prefill()
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Your budget")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {

                Text(Currency.string(from: budget))
                    .font(.system(
                        size: 36,
                        weight: .bold,
                        design: .rounded
                    ))

                Text("per \(budgetType.unitName)")
                    .font(.system(
                        size: 15,
                        weight: .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {

                Button {
                    clear()
                } label: {
                    Text("Remove")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.red)
                }

                Spacer()

                Button {
                    startEditing()
                } label: {
                    Text("Edit")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 26)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 18) {

            VStack(alignment: .leading, spacing: 4) {

                Text(hasBudget ? "Edit budget" : "Set your budget")
                    .font(.system(
                        size: 20,
                        weight: .bold,
                        design: .rounded
                    ))

                Text("One budget, reset on the period you pick.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {

                Text("Resets every")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Picker("Resets every", selection: $period) {
                    ForEach(BudgetType.selectable, id: \.self) { type in
                        Text(type.displayName)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            CurrencyField(amount: $amount, fontSize: 36)

            HStack(spacing: 14) {

                if hasBudget {
                    Button {
                        cancelEditing()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button {
                    save()
                } label: {
                    Text("Save budget")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(amount > 0 ? Color.blue : Color.secondary)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .disabled(amount <= 0)
            }
        }
    }

    private func prefill() {
        period = budgetType == .none
            ? .monthly
            : budgetType
        amount = Int(budget)
    }

    private func startEditing() {
        prefill()

        withAnimation(.spring) {
            isEditing = true
        }
    }

    private func cancelEditing() {
        prefill()

        withAnimation(.spring) {
            isEditing = false
        }
    }

    private func save() {
        let data = AppData.current(in: modelContext)
        data.budgetType = period
        data.budget = Double(amount)

        do {
            try modelContext.save()

            withAnimation(.spring) {
                isEditing = false
            }
        } catch {
            print("Failed to save budget: \(error)")
        }
    }

    private func clear() {
        let data = AppData.current(in: modelContext)
        data.budgetType = .none
        data.budget = 0

        do {
            try modelContext.save()
        } catch {
            print("Failed to clear budget: \(error)")
        }
    }
}

#Preview {
    BudgetEditorCard()
}
