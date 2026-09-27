# Fae

A modern expense tracking app built with SwiftUI and SwiftData.

## Features

- **Home Dashboard** - Overview of spending across different time periods (Today, Week, Month, Year)
- **Budget Management** - Set and track budgets with visual progress indicators
- **Spending Analytics** - Charts showing spending trends, category breakdowns, and weekday patterns
- **Transaction Logging** - Quick and easy expense entry with merchant tracking
- **Transaction History** - Searchable list of all transactions with swipe-to-delete

## Screenshots

> **Note:** Add your screenshots in the screenshots folder below

### Home Screen
<!-- ![Home Screen](screenshots/home.png) -->

### Add Transaction
<!-- ![Add Transaction](screenshots/add-transaction.png) -->

### Budget View
<!-- ![Budget View](screenshots/budget.png) -->

### Spending Charts
<!-- ![Spending Charts](screenshots/charts.png) -->

### Transaction History
<!-- ![Transaction History](screenshots/history.png) -->

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Technology Stack

- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData
- **Charts:** Swift Charts

## Project Structure

```
Fae/
├── FaeApp.swift              # App entry point
├── AppData.swift             # Shared app state and budget data
├── AppRootView.swift         # Root view with data initialization
├── ContentView.swift         # Main tab view
├── HomeView.swift            # Home dashboard
├── BudgetView.swift          # Budget management screen
├── HistoryView.swift         # Transaction history with search
├── AddTransactionView.swift  # Add transaction tab
├── LogTransactionView.swift  # Transaction logging form
├── TransactionDetailView.swift # Individual transaction details
├── TransactionRecorder.swift  # Transaction persistence logic
├── SpendingStats.swift        # Spending calculations and analytics
├── Constants.swift            # App-wide constants
├── Currency.swift             # Currency formatting utilities
├── Transaction.swift          # Transaction data model
├── VerticalListView.swift     # Reusable transaction list view
├── VerticalScrollView.swift   # Reusable scroll view component
└── Components/
    ├── BudgetEditorCard.swift     # Budget editing interface
    ├── BudgetPaceChart.swift      # Budget pace visualization
    ├── BudgetProgressCard.swift   # Budget progress display
    ├── CategoryBreakdownChart.swift # Category spending donut chart
    ├── CurrencyField.swift        # Currency input field
    ├── KeyboardDoneButton.swift   # Keyboard dismiss button
    ├── PeriodSelector.swift       # Time period selector
    ├── SpendingTrendChart.swift   # Spending trend bar chart
    ├── SwipeButton.swift          # Swipe-to-activate button
    └── WeekdaySpendingChart.swift # Weekday spending chart
```

## License

MIT License
