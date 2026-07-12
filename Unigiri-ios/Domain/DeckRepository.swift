import Foundation

@MainActor
protocol DeckRepository {
    func fetchDecks() throws -> [DeckModel]
    func saveDeck(_ deck: DeckModel) throws
    func deleteDeck(id: UUID) throws
}
