import Foundation
import SwiftData

@MainActor
final class DeckRepositoryImpl: DeckRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchDecks() throws -> [DeckModel] {
        let descriptor = FetchDescriptor<DeckEntity>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { toModel($0) }
    }

    func saveDeck(_ deck: DeckModel) throws {
        if let existing = try fetchEntity(id: deck.id) {
            existing.name = deck.name
            existing.updatedAt = deck.updatedAt
            existing.cards.forEach { context.delete($0) }
            existing.cards = deck.cards.map { toCardEntity($0) }
        } else {
            let entity = DeckEntity(
                id: deck.id,
                name: deck.name,
                createdAt: deck.createdAt,
                updatedAt: deck.updatedAt,
                cards: deck.cards.map { toCardEntity($0) }
            )
            context.insert(entity)
        }
        try context.save()
    }

    func deleteDeck(id: UUID) throws {
        guard let entity = try fetchEntity(id: id) else { return }
        context.delete(entity)
        try context.save()
    }

    // MARK: - Private

    private func fetchEntity(id: UUID) throws -> DeckEntity? {
        let descriptor = FetchDescriptor<DeckEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    private func toModel(_ entity: DeckEntity) -> DeckModel {
        DeckModel(
            id: entity.id,
            name: entity.name,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            cards: entity.cards
                .sorted { $0.sortOrder < $1.sortOrder }
                .map {
                    DeckCardModel(
                        cardId: $0.cardId,
                        title: $0.title,
                        img: $0.img,
                        cardType: $0.cardType,
                        pack: $0.pack,
                        count: $0.count,
                        sortOrder: $0.sortOrder
                    )
                }
        )
    }

    private func toCardEntity(_ card: DeckCardModel) -> DeckCardEntity {
        DeckCardEntity(
            cardId: card.cardId,
            title: card.title,
            img: card.img,
            cardType: card.cardType,
            pack: card.pack,
            count: card.count,
            sortOrder: card.sortOrder
        )
    }
}
