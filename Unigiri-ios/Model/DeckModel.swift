import Foundation

struct DeckModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    let createdAt: Date
    var updatedAt: Date
    var cards: [DeckCardModel]

    var totalCount: Int {
        cards.reduce(0) { $0 + $1.count }
    }

    var characterCount: Int {
        cards.filter { $0.cardType == DeckValidator.characterCardType }
            .reduce(0) { $0 + $1.count }
    }
}

struct DeckCardModel: Identifiable, Equatable {
    let cardId: String
    let title: String
    let img: String
    let cardType: String
    let pack: [String]
    var count: Int
    var sortOrder: Int

    var id: String { cardId }
}

extension DeckCardModel {
    init(card: ZutocaModel, count: Int, sortOrder: Int) {
        self.cardId = card.id
        self.title = card.title
        self.img = card.img
        self.cardType = card.cardType
        self.pack = card.pack
        self.count = count
        self.sortOrder = sortOrder
    }
}
