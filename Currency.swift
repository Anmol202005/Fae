import Foundation

enum Currency {

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static func string(from value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "₹0"
    }

    static func string(from value: Int) -> String {
        string(from: Double(value))
    }

    static func compactString(from value: Double) -> String {
        "₹" + value.formatted(.number.notation(.compactName))
    }
}
