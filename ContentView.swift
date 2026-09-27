import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            Tab(Constants.homeString, systemImage: Constants.homeStringIcon){
                HomeView()
            }

            Tab(Constants.addString, systemImage: Constants.addStringIcon){
                AddTransactionView()
            }

            Tab(Constants.budgetString, systemImage: Constants.budgetStringIcon){
                BudgetView()
            }

            Tab(Constants.historyString, systemImage: Constants.historyStringIcon){
                HistoryView()
            }
        }
    }
}

#Preview {
    ContentView()
}
