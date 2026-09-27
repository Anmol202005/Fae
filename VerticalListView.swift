import SwiftUI
import SwiftData

struct VerticalListView: View {
    
    var transactions: [Transaction]
    let onSelect : (Transaction) -> Void

    @Environment(\.modelContext) var modelContext

    var body: some View {
        List(transactions) { transaction in

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
            .padding(.vertical, 12)
            .onTapGesture {
                onSelect(transaction)
            }
            .swipeActions {
                Button {
                    modelContext.delete(transaction)
                    try? modelContext.save()
                } label: {
                    Image(systemName: "trash")
                        .tint(.red)
                }
            }
        }
    }
}

#Preview {
    VerticalListView(transactions: Transaction.priviewTransactions) { transaction in
        
    }
}
