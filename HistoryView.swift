import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @State private var transactionDetailPath = NavigationPath()
    @State private var query = ""

    @Query(sort: \Transaction.timestamp, order: .reverse)
    private var transactions: [Transaction]

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var results: [Transaction] {

        let needle = trimmedQuery.lowercased()

        guard !needle.isEmpty else {
            return transactions
        }

        return transactions.filter { transaction in

            transaction.payee.lowercased().contains(needle)
            || (transaction.note ?? "").lowercased().contains(needle)
            || (transaction.category ?? "").lowercased().contains(needle)
            || String(transaction.amount).contains(needle)
        }
    }

    var body: some View {

        NavigationStack(path: $transactionDetailPath) {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("History")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal)
                    .padding(.vertical)
                
                searchField
                
                if transactions.isEmpty {
                    
                    message(
                        icon: "tray",
                        title: "No Recent Transactions",
                        subtitle: "Your transactions will appear here"
                    )
                    
                    Spacer()
                    
                } else if results.isEmpty {
                    
                    message(
                        icon: "magnifyingglass",
                        title: "No Matches",
                        subtitle: "Nothing found for \"\(trimmedQuery)\""
                    )
                    
                    Spacer()
                    
                } else {
                    
                    VerticalListView(transactions: results){ transaction in
                        transactionDetailPath.append(transaction)
                    }
                }
            }
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .keyboardDoneButton()
        }
    }

    private var searchField: some View {

        HStack(spacing: 12) {

            Image(systemName: Constants.searchStringIcon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField("Search transactions", text: $query)
                .font(.system(size: 16, design: .rounded))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !query.isEmpty {

                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func message(
        icon: String,
        title: String,
        subtitle: String
    ) -> some View {

        VStack(spacing: 12) {

            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.secondary)

            VStack(spacing: 4) {

                Text(title)
                    .font(.system(
                        size: 20,
                        weight: .semibold,
                        design: .rounded
                    ))

                Text(subtitle)
                    .font(.system(
                        size: 14,
                        design: .rounded
                    ))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .padding(.horizontal)
    }
}

#Preview {
    HistoryView()
}
