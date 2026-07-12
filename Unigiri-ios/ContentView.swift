import SwiftUI

enum Tab {
    case battle
    case cardList
    case deck
}

struct ContentView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var deckListViewModel: DeckListViewModel
    let makeDeckEditViewModel: (DeckModel?) -> DeckEditViewModel
    @State private var selectedTab: Tab = .battle
    @State private var showSheet = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                BattleScreen()
                    .tabItem {
                        Image(systemName: "shield.lefthalf.filled")
                        Text("Battle")
                    }
                    .tag(Tab.battle)

                SearchScreen(viewModel: viewModel)
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("CardList")
                    }
                    .tag(Tab.cardList)

                DeckListScreen(
                    viewModel: deckListViewModel,
                    makeEditViewModel: makeDeckEditViewModel
                )
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("Deck")
                }
                .tag(Tab.deck)
            }

            if selectedTab == .cardList {
                Button {
                    showSheet = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 80)
            }
        }
        .sheet(isPresented: $showSheet) {
            FilterBottomSheet(viewModel: viewModel)
        }
    }
}
