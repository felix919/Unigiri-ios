import SwiftUI

struct SearchScreen: View {
    @ObservedObject var viewModel: SearchViewModel

    @State private var selectedCard: ZutocaModel?

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ZStack {
            Color.mainPurple
                .ignoresSafeArea()

            if viewModel.uiState.isLoading {
                ProgressView()
            } else if let error = viewModel.uiState.error {
                Text(error)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.uiState.result) { item in
                            CardView(item: item)
                                .onTapGesture {
                                    selectedCard = item
                                }
                        }
                    }
                    .padding(4)
                }
            }
        }
        .fullScreenCover(item: $selectedCard) { card in
            CardDetailScreen(card: card)
        }
    }
}
