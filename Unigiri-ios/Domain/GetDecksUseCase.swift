import Foundation

@MainActor
class GetDecksUseCase {
    private let repository: DeckRepository

    init(repository: DeckRepository) {
        self.repository = repository
    }

    func execute() throws -> [DeckModel] {
        try repository.fetchDecks()
    }
}
