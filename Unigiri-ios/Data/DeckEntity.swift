import Foundation
import SwiftData

@Model
final class DeckEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \DeckCardEntity.deck)
    var cards: [DeckCardEntity]

    init(id: UUID, name: String, createdAt: Date, updatedAt: Date, cards: [DeckCardEntity]) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.cards = cards
    }
}

@Model
final class DeckCardEntity {
    var cardId: String
    var title: String
    var img: String
    var cardType: String
    var pack: [String]
    var count: Int
    var sortOrder: Int
    var deck: DeckEntity?

    init(
        cardId: String,
        title: String,
        img: String,
        cardType: String,
        pack: [String],
        count: Int,
        sortOrder: Int
    ) {
        self.cardId = cardId
        self.title = title
        self.img = img
        self.cardType = cardType
        self.pack = pack
        self.count = count
        self.sortOrder = sortOrder
    }
}
