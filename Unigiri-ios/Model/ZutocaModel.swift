import Foundation

struct ZutocaModel: Identifiable, Equatable {
    let id: String
    let pack: [String]
    let title: String
    let songs: String
    let illustrator: String
    let rare: String
    let type: String
    let cardType: String
    let clock: Int
    let nightAttack: Int?
    let noonAttack: Int?
    let effect: String
    let cost: Int
    let power: Int
    let img: String
    let topDisplay: String
    let isPublic: String
}
