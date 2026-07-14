import Foundation

struct HandCard: Identifiable, Equatable {
    // 同名カード(count=2)を別インスタンスとして扱うためのID (スロット展開順 0..19)
    let instanceId: Int
    let card: DeckCardModel
    var isRedrawn = false

    var id: Int { instanceId }
}

/// 初期手札シミュレーション (公式ルール: 開始時に5枚ドロー、1回だけ任意枚数を引き直し可)
/// 「引き直しは1回のみ」はUI側のフェーズ管理で担保する
enum HandSimulator {
    static let handSize = 5

    struct DealtHand: Equatable {
        let hand: [HandCard]
        let pile: [HandCard]
    }

    static func deal(deck: DeckModel) -> DealtHand {
        var generator = SystemRandomNumberGenerator()
        return deal(deck: deck, using: &generator)
    }

    static func deal(deck: DeckModel, using generator: inout some RandomNumberGenerator) -> DealtHand {
        let slots = deck.cards
            .sorted { $0.sortOrder < $1.sortOrder }
            .flatMap { card in Array(repeating: card, count: card.count) }
            .enumerated()
            .map { index, card in HandCard(instanceId: index, card: card) }
        precondition(slots.count == DeckValidator.deckSize, "デッキが\(DeckValidator.deckSize)枚ではありません")

        let shuffled = slots.shuffled(using: &generator)
        return DealtHand(
            hand: Array(shuffled.prefix(handSize)),
            pile: Array(shuffled.dropFirst(handSize))
        )
    }

    // 選択カードを同じスロット位置で山札の先頭から置換する (pileは既にランダム順なのでRNG不要)
    // 選択カードは山札に戻さない
    static func mulligan(
        hand: [HandCard],
        selectedIds: Set<Int>,
        pile: [HandCard]
    ) -> [HandCard] {
        var drawIndex = 0
        return hand.map { handCard in
            if selectedIds.contains(handCard.instanceId) {
                var drawn = pile[drawIndex]
                drawIndex += 1
                drawn.isRedrawn = true
                return drawn
            } else {
                return handCard
            }
        }
    }
}
