import Foundation

struct DeckValidationState {
    var totalCount = 0
    var characterCount = 0
    var copyCounts: [String: Int] = [:]

    var isComplete: Bool {
        totalCount == DeckValidator.deckSize
    }

    func canAdd(_ cardId: String) -> Bool {
        totalCount < DeckValidator.deckSize &&
        (copyCounts[cardId] ?? 0) < DeckValidator.maxCopies
    }

    // 公式ルール上キャラクターカード50%以上は推奨 (保存はブロックしない)
    var showsCharacterWarning: Bool {
        totalCount > 0 && characterCount * 2 < totalCount
    }
}

enum DeckValidationError: LocalizedError {
    case tooManyCards(count: Int)
    case tooManyCopies(title: String)

    var errorDescription: String? {
        switch self {
        case .tooManyCards(let count):
            return "デッキは\(DeckValidator.deckSize)枚までです (現在\(count)枚)"
        case .tooManyCopies(let title):
            return "「\(title)」は\(DeckValidator.maxCopies)枚までです"
        }
    }
}

enum DeckValidator {
    static let deckSize = 20
    static let maxCopies = 2
    static let characterCardType = "Character"

    static func makeState(cards: [DeckCardModel]) -> DeckValidationState {
        var state = DeckValidationState()
        for card in cards {
            state.totalCount += card.count
            if card.cardType == characterCardType {
                state.characterCount += card.count
            }
            state.copyCounts[card.cardId] = (state.copyCounts[card.cardId] ?? 0) + card.count
        }
        return state
    }

    static func validateHardRules(_ deck: DeckModel) throws {
        if deck.totalCount > deckSize {
            throw DeckValidationError.tooManyCards(count: deck.totalCount)
        }
        if let over = deck.cards.first(where: { $0.count > maxCopies }) {
            throw DeckValidationError.tooManyCopies(title: over.title)
        }
    }
}
