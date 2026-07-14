import SwiftData
import SwiftUI

@main
struct Unigiri_iosApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var deckListViewModel: DeckListViewModel

    init() {
        AppAppearance.configure()

        let container = try! ModelContainer(for: DeckEntity.self)
        self.modelContainer = container
        _deckListViewModel = StateObject(
            wrappedValue: DeckListViewModel(modelContext: container.mainContext)
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: searchViewModel,
                deckListViewModel: deckListViewModel,
                makeDeckEditViewModel: { [modelContainer] deck in
                    DeckEditViewModel(
                        modelContext: modelContainer.mainContext,
                        existingDeck: deck
                    )
                }
            )
            // 全画面ダークモード固定
            .preferredColorScheme(.dark)
        }
    }
}
