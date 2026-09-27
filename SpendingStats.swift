import Foundation

extension Transaction {

    var effectiveDate: Date {
        date ?? Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

extension BudgetType {

    static var selectable: [BudgetType] {
        [.daily, .weekly, .monthly, .yearly]
    }

    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        case .none:
            return "None"
        }
    }

    var unitName: String {
        switch self {
        case .daily:
            return "day"
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        case .yearly:
            return "year"
        case .none:
            return "period"
        }
    }

    func interval(
        containing date: Date,
        calendar: Calendar = .current
    ) -> DateInterval {

        switch self {
        case .daily:
            return calendar.dateInterval(of: .day, for: date)
                ?? DateInterval(start: date, duration: 0)
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: date)
                ?? DateInterval(start: date, duration: 0)
        case .monthly:
            return calendar.dateInterval(of: .month, for: date)
                ?? DateInterval(start: date, duration: 0)
        case .yearly:
            return calendar.dateInterval(of: .year, for: date)
                ?? DateInterval(start: date, duration: 0)
        case .none:
            return DateInterval(start: date, duration: 0)
        }
    }

    func daysInPeriod(
        containing date: Date,
        calendar: Calendar = .current
    ) -> Double {

        switch self {
        case .daily:
            return 1
        case .weekly:
            return 7
        case .monthly:
            return Double(
                calendar.range(of: .day, in: .month, for: date)?.count ?? 30
            )
        case .yearly:
            return Double(
                calendar.range(of: .day, in: .year, for: date)?.count ?? 365
            )
        case .none:
            return 1
        }
    }
}

enum TrendRange: String, CaseIterable, Identifiable {

    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }

    var title: String { rawValue }

    var axisComponent: Calendar.Component {
        switch self {
        case .week, .month:
            return .day
        case .year:
            return .month
        }
    }
}

struct TrendPoint: Identifiable {

    let date: Date
    let amount: Double

    var id: Date { date }
}

struct CategoryTotal: Identifiable {

    let category: String
    let amount: Double

    var id: String { category }
}

enum SpendingStats {

    static func total(
        of transactions: [Transaction],
        in interval: DateInterval
    ) -> Double {

        transactions.reduce(0) { result, transaction in
            guard interval.contains(transaction.effectiveDate) else {
                return result
            }
            return result + Double(transaction.amount)
        }
    }

    static func trend(
        of transactions: [Transaction],
        range: TrendRange,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [TrendPoint] {

        switch range {
        case .week:
            guard let interval = calendar.dateInterval(
                of: .weekOfYear,
                for: now
            ) else {
                return []
            }
            return dailyBuckets(
                of: transactions,
                in: interval,
                upTo: now,
                calendar: calendar
            )
        case .month:
            guard let interval = calendar.dateInterval(
                of: .month,
                for: now
            ) else {
                return []
            }
            return dailyBuckets(
                of: transactions,
                in: interval,
                upTo: now,
                calendar: calendar
            )
        case .year:
            guard let interval = calendar.dateInterval(
                of: .year,
                for: now
            ) else {
                return []
            }
            return monthlyBuckets(
                of: transactions,
                in: interval,
                upTo: now,
                calendar: calendar
            )
        }
    }

    static func categoryTotals(
        of transactions: [Transaction],
        in interval: DateInterval
    ) -> [CategoryTotal] {

        var totals: [String: Double] = [:]

        for transaction in transactions {
            guard interval.contains(transaction.effectiveDate) else {
                continue
            }

            let category: String
            if let stored = transaction.category, !stored.isEmpty {
                category = stored
            } else {
                category = "Other"
            }

            totals[category, default: 0] += Double(transaction.amount)
        }

        return totals
            .map { CategoryTotal(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    private static func dailyBuckets(
        of transactions: [Transaction],
        in interval: DateInterval,
        upTo now: Date,
        calendar: Calendar
    ) -> [TrendPoint] {

        var totals: [Date: Double] = [:]

        let lastDay = calendar.startOfDay(for: now)
        var day = calendar.startOfDay(for: interval.start)

        while day < interval.end && day <= lastDay {
            totals[day] = 0

            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else {
                break
            }
            day = next
        }

        for transaction in transactions {
            let date = transaction.effectiveDate
            guard interval.contains(date), date <= now else { continue }

            let bucket = calendar.startOfDay(for: date)
            guard totals[bucket] != nil else { continue }

            totals[bucket, default: 0] += Double(transaction.amount)
        }

        return totals.keys.sorted().map {
            TrendPoint(date: $0, amount: totals[$0] ?? 0)
        }
    }

    private static func monthlyBuckets(
        of transactions: [Transaction],
        in interval: DateInterval,
        upTo now: Date,
        calendar: Calendar
    ) -> [TrendPoint] {

        var totals: [Date: Double] = [:]

        for monthOffset in 0..<12 {
            guard let monthStart = calendar.date(
                byAdding: .month,
                value: monthOffset,
                to: interval.start
            ) else {
                continue
            }

            guard monthStart <= now else { break }
            totals[calendar.startOfDay(for: monthStart)] = 0
        }

        for transaction in transactions {
            let date = transaction.effectiveDate
            guard interval.contains(date), date <= now else { continue }

            guard let monthStart = calendar.dateInterval(
                of: .month,
                for: date
            )?.start else {
                continue
            }

            let bucket = calendar.startOfDay(for: monthStart)
            guard totals[bucket] != nil else { continue }

            totals[bucket, default: 0] += Double(transaction.amount)
        }

        return totals.keys.sorted().map {
            TrendPoint(date: $0, amount: totals[$0] ?? 0)
        }
    }
}
