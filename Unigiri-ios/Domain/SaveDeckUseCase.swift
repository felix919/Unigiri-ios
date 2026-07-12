import Foundation

@MainActor
class SaveDeckUseCase {
    private let repository: DeckRepository

    init(repository: DeckRepository) {
        self.repository = repository
    }

    func execute(_ deck: DeckModel) throws {
        try DeckValidator.validateHardRules(deck)
        try repository.saveDeck(deck)
    }
}
