import SwiftUI

struct PeriodSelector: View {
    enum Period {
        case today
        case week
        case month
        case year
    }

    @Binding var selectedPeriod: Period

    var body: some View {
        VStack(spacing: 10) {
            periodButton(.today)
            periodButton(.week)
            periodButton(.month)
            periodButton(.year)
        }
        .frame(width: 32)
    }

    private func periodButton(_ period: Period) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPeriod = period
            }
        } label: {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    selectedPeriod == period
                    ? Color.primary
                    : Color.secondary.opacity(0.25)
                )
                .frame(
                    width: selectedPeriod == period ? 28 : 20,
                    height: 5
                )
        }
        .buttonStyle(.plain)
    }
}
