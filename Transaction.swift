import Foundation
import SwiftData

@Model
class Transaction {
    var timestamp: Int
    var amount: Int
    var payee: String
    var note: String?
    var category: String?
    var date: Date?
    var transactionID: String

    init(
        timestamp: Int,
        amount: Int,
        payee: String,
        note: String? = nil,
        category: String? = nil,
        date: Date? = nil,
        transactionID: String
    ) {
        self.timestamp = timestamp
        self.amount = amount
        self.payee = payee
        self.note = note
        self.category = category
        self.date = date
        self.transactionID = transactionID
    }

    static var priviewTransactions = [
        Transaction(
            timestamp: 1,
            amount: 1200,
            payee: "Swiggy",
            note: "Dinner",
            category: "Food",
            date: Date(),
            transactionID: "654345678"
        ),
        Transaction(
            timestamp: 2,
            amount: 6500,
            payee: "Blinkit",
            category: "Shopping",
            date: Date(),
            transactionID: "654345679"
        ),
        Transaction(
            timestamp: 3,
            amount: 5400,
            payee: "Zomato",
            transactionID: "654567213"
        )
    ]
}
