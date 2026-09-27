import SwiftUI

struct VerticalScrollView: View {
    let title: String
    let transactions: [Transaction]
    let onSelect : (Transaction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .frame(maxWidth:.infinity ,alignment: .leading)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .padding(.horizontal)
                .padding(.top, 30)
            
            if transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.secondary)

                    VStack(spacing: 4) {
                        Text("No Recent Transactions")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))

                        Text("Your transactions will appear here")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
            }else {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                        HStack(spacing: 14) {
                            Image(systemName: "indianrupeesign.bank.building")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 42, height: 42)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(transaction.payee)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))

                                Text("Expense")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("-₹\(transaction.amount)")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .onTapGesture {
                            onSelect(transaction)
                        }
                        .padding(.vertical, 12)
                        if index < transactions.count - 1 {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    VerticalScrollView(
        title: "Recent Transactions",
        transactions: Transaction.priviewTransactions
    ){
        transaction in
    }
}
