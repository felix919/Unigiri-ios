import Foundation

@MainActor
class DeleteDeckUseCase {
    private let repository: DeckRepository

    init(repository: DeckRepository) {
        self.repository = repository
    }

    func execute(id: UUID) throws {
        try repository.deleteDeck(id: id)
    }
}
