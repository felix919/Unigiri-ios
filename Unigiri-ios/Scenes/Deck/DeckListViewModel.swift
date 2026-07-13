import Combine
import Foundation
import SwiftData

@MainActor
class DeckListViewModel: ObservableObject {
    @Published var uiState = DeckListUiState()

    private let interactor: DeckInteractor
    private let imageRenderer = DeckImageRenderer()

    init(modelContext: ModelContext) {
        let repository = DeckRepositoryImpl(context: modelContext)
        self.interactor = DeckInteractor(
            getDecksUseCase: GetDecksUseCase(repository: repository),
            saveDeckUseCase: SaveDeckUseCase(repository: repository),
            deleteDeckUseCase: DeleteDeckUseCase(repository: repository)
        )
    }

    func load() {
        do {
            uiState.decks = try interactor.fetchDecks()
            uiState.error = nil
        } catch {
            uiState.error = error.localizedDescription
        }
    }

    func delete(at offsets: IndexSet) {
        do {
            for index in offsets {
                try interactor.delete(id: uiState.decks[index].id)
            }
        } catch {
            uiState.error = error.localizedDescription
        }
        load()
    }

    func delete(deck: DeckModel) {
        do {
            try interactor.delete(id: deck.id)
        } catch {
            uiState.error = error.localizedDescription
        }
        load()
    }

    func shareDeckImage(_ deck: DeckModel) {
        Task {
            uiState.isGeneratingShareImage = true
            do {
                let image = try await imageRenderer.render(deck: deck)
                uiState.shareItem = ShareImageItem(image: image)
            } catch {
                uiState.shareError = "画像の取得に失敗しました"
            }
            uiState.isGeneratingShareImage = false
        }
    }
}
