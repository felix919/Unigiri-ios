import Foundation

@MainActor
class DeckInteractor {
    private let getDecksUseCase: GetDecksUseCase
    private let saveDeckUseCase: SaveDeckUseCase
    private let deleteDeckUseCase: DeleteDeckUseCase

    init(
        getDecksUseCase: GetDecksUseCase,
        saveDeckUseCase: SaveDeckUseCase,
        deleteDeckUseCase: DeleteDeckUseCase
    ) {
        self.getDecksUseCase = getDecksUseCase
        self.saveDeckUseCase = saveDeckUseCase
        self.deleteDeckUseCase = deleteDeckUseCase
    }

    func fetchDecks() throws -> [DeckModel] {
        try getDecksUseCase.execute()
    }

    func save(_ deck: DeckModel) throws {
        try saveDeckUseCase.execute(deck)
    }

    func delete(id: UUID) throws {
        try deleteDeckUseCase.execute(id: id)
    }
}
