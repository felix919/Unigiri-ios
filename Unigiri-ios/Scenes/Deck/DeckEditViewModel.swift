import Combine
import Foundation
import SwiftData

@MainActor
class DeckEditViewModel: ObservableObject {
    @Published var uiState = DeckEditUiState()

    private let deckInteractor: DeckInteractor
    private let existingDeck: DeckModel?

    init(modelContext: ModelContext, existingDeck: DeckModel? = nil) {
        let deckRepository = DeckRepositoryImpl(context: modelContext)
        self.deckInteractor = DeckInteractor(
            getDecksUseCase: GetDecksUseCase(repository: deckRepository),
            saveDeckUseCase: SaveDeckUseCase(repository: deckRepository),
            deleteDeckUseCase: DeleteDeckUseCase(repository: deckRepository)
        )

        self.existingDeck = existingDeck
        if let deck = existingDeck {
            uiState.deckName = deck.name
            uiState.selectedEntries = deck.cards.sorted { $0.sortOrder < $1.sortOrder }
            uiState.validation = DeckValidator.makeState(cards: deck.cards)
        }
    }

    func addCard(_ card: ZutocaModel) {
        guard uiState.validation.canAdd(card.id) else { return }

        if let index = uiState.selectedEntries.firstIndex(where: { $0.cardId == card.id }) {
            uiState.selectedEntries[index].count += 1
        } else {
            uiState.selectedEntries.append(
                DeckCardModel(card: card, count: 1, sortOrder: uiState.selectedEntries.count)
            )
        }
        revalidate()
    }

    func removeCard(_ cardId: String) {
        guard let index = uiState.selectedEntries.firstIndex(where: { $0.cardId == cardId }) else { return }

        if uiState.selectedEntries[index].count > 1 {
            uiState.selectedEntries[index].count -= 1
        } else {
            uiState.selectedEntries.remove(at: index)
        }
        revalidate()
    }

    func copyCount(of cardId: String) -> Int {
        uiState.validation.copyCounts[cardId] ?? 0
    }

    func save() -> Bool {
        let trimmedName = uiState.deckName.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date()
        var cards = uiState.selectedEntries
        for index in cards.indices {
            cards[index].sortOrder = index
        }

        let deck = DeckModel(
            id: existingDeck?.id ?? UUID(),
            name: trimmedName.isEmpty ? "新しいデッキ" : trimmedName,
            createdAt: existingDeck?.createdAt ?? now,
            updatedAt: now,
            cards: cards
        )

        do {
            try deckInteractor.save(deck)
            return true
        } catch {
            uiState.saveError = error.localizedDescription
            return false
        }
    }

    // MARK: - Private

    private func revalidate() {
        uiState.validation = DeckValidator.makeState(cards: uiState.selectedEntries)
    }
}
