import Foundation
import SwiftData

@Model
class AppData {

    var yearlyExpense: Double
    var monthlyExpense: Double
    var weeklyExpense: Double
    var dailyExpense: Double
    var budget: Double
    var budgetType: BudgetType

    var lastDay: Date
    var lastWeek: Date
    var lastMonth: Date
    var lastYear: Date

    init(
        yearlyExpense: Double = 0,
        monthlyExpense: Double = 0,
        weeklyExpense: Double = 0,
        dailyExpense: Double = 0,
        budget: Double = 0,
        budgetType: BudgetType = .none
    ) {
        self.yearlyExpense = yearlyExpense
        self.monthlyExpense = monthlyExpense
        self.weeklyExpense = weeklyExpense
        self.dailyExpense = dailyExpense
        self.budget = budget
        self.budgetType = budgetType

        let now = Date()

        self.lastDay = now
        self.lastWeek = now
        self.lastMonth = now
        self.lastYear = now
    }
}

enum BudgetType: Codable {
    case daily
    case weekly
    case monthly
    case yearly
    case none
}
extension AppData {
    func resetExpiredPeriods() {
        let calendar = Calendar.current
        let now = Date()

        if !calendar.isDate(lastDay, inSameDayAs: now) {
            dailyExpense = 0
            lastDay = now
        }

        if !calendar.isDate(
            lastWeek,
            equalTo: now,
            toGranularity: .weekOfYear
        ) {
            weeklyExpense = 0
            lastWeek = now
        }

        if !calendar.isDate(
            lastMonth,
            equalTo: now,
            toGranularity: .month
        ) {
            monthlyExpense = 0
            lastMonth = now
        }

        if !calendar.isDate(
            lastYear,
            equalTo: now,
            toGranularity: .year
        ) {
            yearlyExpense = 0
            lastYear = now
        }
    }
}

extension AppData {

    static func current(in context: ModelContext) -> AppData {

        let all = (try? context.fetch(FetchDescriptor<AppData>())) ?? []

        guard let existing = all.first else {
            let data = AppData()
            context.insert(data)
            return data
        }

        for duplicate in all.dropFirst() {
            context.delete(duplicate)
        }

        return existing
    }
}
