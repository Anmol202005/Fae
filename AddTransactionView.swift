import SwiftUI
import SwiftData

struct AddTransactionView: View {

    @Query(sort: \Transaction.timestamp, order: .reverse)
    private var transactions: [Transaction]

    @State private var prefill: MerchantPrefill?

    private var recentMerchants: [String] {

        var seen = Set<String>()
        var names: [String] = []

        for transaction in transactions {

            let name = transaction.payee.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            guard !name.isEmpty else {
                continue
            }

            let key = name.lowercased()

            guard !seen.contains(key) else {
                continue
            }

            seen.insert(key)
            names.append(name)

            if names.count == 8 {
                break
            }
        }

        return names
    }

    var body: some View {
        ScrollView {

            VStack(spacing: 20) {

                Text("Add Transaction")
                    .font(.system(size: 22, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical)

                LogTransactionView(prefill: prefill)

                if !recentMerchants.isEmpty {
                    quickAdd
                }
            }
            .padding(.bottom)
        }
    }

    private var quickAdd: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Quick add")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 10) {

                    ForEach(recentMerchants, id: \.self) { name in

                        Button {
                            prefill = MerchantPrefill(name: name)
                        } label: {

                            HStack(spacing: 8) {

                                Image(systemName: "arrow.counterclockwise")
                                    .font(.caption)

                                Text(name)
                                    .font(.system(
                                        size: 15,
                                        weight: .semibold,
                                        design: .rounded
                                    ))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    AddTransactionView()
}
