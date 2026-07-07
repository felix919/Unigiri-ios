import SwiftUI

struct SearchScreen: View {
    @ObservedObject var viewModel: SearchViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ZStack {
            if viewModel.uiState.isLoading {
                ProgressView()
            } else if let error = viewModel.uiState.error {
                Text(error)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(viewModel.uiState.result) { item in
                            CardView(item: item)
                        }
                    }
                    .padding(4)
                }
            }
        }
    }
}
