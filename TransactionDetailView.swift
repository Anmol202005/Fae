import SwiftUI

struct TransactionDetailView: View {

    let transaction: Transaction

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                VStack(spacing: 8) {

                    Text("-₹\(transaction.amount)")
                        .font(.system(
                            size: 42,
                            weight: .bold,
                            design: .rounded
                        ))

                    Text(transaction.payee)
                        .font(.system(
                            size: 20,
                            weight: .semibold,
                            design: .rounded
                        ))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)

                VStack(spacing: 0) {

                    DetailRow(
                        icon: "tag",
                        title: "Category",
                        value: transaction.category ?? "Not specified"
                    )

                    Divider()

                    DetailRow(
                        icon: "calendar",
                        title: "Date",
                        value: transaction.date?.formatted(
                            date: .abbreviated,
                            time: .omitted
                        ) ?? "Not specified"
                    )

                    if let note = transaction.note, !note.isEmpty {

                        Divider()

                        DetailRow(
                            icon: "note.text",
                            title: "Note",
                            value: note
                        )
                    }

                    Divider()

                    DetailRow(
                        icon: "number",
                        title: "Transaction ID",
                        value: transaction.transactionID
                    )
                }
                .padding(.horizontal, 18)
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 36, height: 36)
                .background(.thinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )

            VStack(alignment: .leading, spacing: 3) {

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(
                        size: 16,
                        weight: .medium,
                        design: .rounded
                    ))
            }

            Spacer()
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(
            transaction: Transaction.priviewTransactions[0]
        )
    }
}
