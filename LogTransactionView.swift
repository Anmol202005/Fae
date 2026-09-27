import SwiftUI
import SwiftData

struct MerchantPrefill: Equatable {

    let name: String
    let id = UUID()
}

struct LogTransactionView: View {

    var prefill: MerchantPrefill?

    @Environment(\.modelContext) private var modelContext

    @State private var amount = 0
    @State private var amountText = ""

    @State private var merchant = ""
    @State private var note = ""
    @State private var showDetails = false
    @State private var showCategories = false
    @State private var selectedCategory = "Other"
    @State private var transactionDate = Date()

    let categories = Constants.spendingCategories

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text("Log Transaction")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 0) {

                Text("₹")
                    .font(.system(
                        size: 48,
                        weight: .bold,
                        design: .rounded
                    ))

                TextField(
                    "0",
                    text: $amountText
                )
                .keyboardType(.numberPad)
                .font(.system(
                    size: 48,
                    weight: .bold,
                    design: .rounded
                ))
                .onChange(of: amountText) { _, newValue in

                    let numbersOnly = newValue.filter { $0.isNumber }

                    if numbersOnly.isEmpty {
                        amountText = ""
                        amount = 0
                        return
                    }

                    let value = Int(numbersOnly) ?? 0
                    amount = value

                    amountText = value.formatted(
                        .number.locale(
                            Locale(identifier: "en_IN")
                        )
                    )
                }
            }

            Button {
                withAnimation(.spring) {
                    showDetails.toggle()
                }
            } label: {
                HStack {
                    Image(
                        systemName: showDetails
                        ? "chevron.up"
                        : "chevron.down"
                    )

                    Text(
                        showDetails
                        ? "Hide details"
                        : "Add details"
                    )

                    Spacer()

                    Text("Optional")
                        .foregroundStyle(.secondary)
                }
                .font(.system(
                    size: 15,
                    weight: .semibold
                ))
            }
            .buttonStyle(.plain)

            if showDetails {

                VStack(spacing: 14) {

                    TextField(
                        "Merchant",
                        text: $merchant
                    )

                    TextField(
                        "Note",
                        text: $note
                    )

                    Button {
                        showCategories = true
                    } label: {
                        HStack {
                            Image(systemName: "tag")

                            Text("Category")

                            Spacer()

                            Text(selectedCategory)
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)

                    DatePicker(
                        selection: $transactionDate,
                        displayedComponents: [.date]
                    ) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Date")
                        }
                    }
                }
                .transition(
                    .opacity.combined(
                        with: .move(edge: .top)
                    )
                )
            }

            SwipeButton(title: "Swipe to add expense") {

                do {
                    try TransactionRecorder.record(
                        amount: amount,
                        payee: merchant.isEmpty
                            ? "Unknown"
                            : merchant,
                        note: note.isEmpty
                            ? nil
                            : note,
                        category: selectedCategory,
                        date: transactionDate,
                        in: modelContext
                    )
                } catch {
                    print("Failed to save transaction: \(error)")
                }

                amount = 0
                amountText = ""
                merchant = ""
                note = ""
                selectedCategory = "Other"
                transactionDate = Date()
                showDetails = false
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .padding(.horizontal)
        .keyboardDoneButton()
        .onChange(of: prefill) { _, newValue in

            guard let newValue else {
                return
            }

            merchant = newValue.name
            showDetails = true
        }
        .sheet(isPresented: $showCategories) {

            NavigationStack {

                List(categories, id: \.self) { category in

                    Button {
                        selectedCategory = category
                        showCategories = false
                    } label: {
                        HStack {

                            Text(category)

                            Spacer()

                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
                .navigationTitle("Category")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    LogTransactionView()
}
