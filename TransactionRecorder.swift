import Foundation
import SwiftData

enum TransactionRecorder {

    @discardableResult
    static func record(
        amount: Int,
        payee: String,
        note: String? = nil,
        category: String? = nil,
        date: Date = Date(),
        in context: ModelContext
    ) throws -> Transaction {

        let transaction = Transaction(
            timestamp: Int(Date().timeIntervalSince1970),
            amount: amount,
            payee: payee.isEmpty ? "Unknown" : payee,
            note: note,
            category: category,
            date: date,
            transactionID: UUID().uuidString
        )

        context.insert(transaction)

        let data = AppData.current(in: context)
        let expense = Double(amount)

        data.resetExpiredPeriods()

        data.dailyExpense += expense
        data.weeklyExpense += expense
        data.monthlyExpense += expense
        data.yearlyExpense += expense

        try context.save()

        return transaction
    }
}
