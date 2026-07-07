import Foundation

struct SearchResultResponse: Decodable {
    let hits: [ZutocaResponse]
    let query: String
    let processingTimeMs: Int
    let limit: Int
    let offset: Int
    let estimatedTotalHits: Int
    let requestUid: String
}

struct ZutocaResponse: Decodable {
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

    enum CodingKeys: String, CodingKey {
        case id, pack, title, songs, illustrator, rare, type
        case cardType = "class"
        case clock
        case nightAttack = "night_attack"
        case noonAttack = "noon_attack"
        case effect, cost, power, img
        case topDisplay = "top_display"
        case isPublic = "public"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        pack = try container.decode([String].self, forKey: .pack)
        title = try container.decode(String.self, forKey: .title)
        songs = try container.decode(String.self, forKey: .songs)
        illustrator = try container.decode(String.self, forKey: .illustrator)
        rare = try container.decode(String.self, forKey: .rare)
        type = try container.decode(String.self, forKey: .type)
        cardType = try container.decode(String.self, forKey: .cardType)
        clock = try container.decode(Int.self, forKey: .clock)

        if let intValue = try? container.decode(Int.self, forKey: .nightAttack) {
            nightAttack = intValue
        } else {
            nightAttack = nil
        }

        if let intValue = try? container.decode(Int.self, forKey: .noonAttack) {
            noonAttack = intValue
        } else {
            noonAttack = nil
        }

        effect = try container.decode(String.self, forKey: .effect)
        cost = try container.decode(Int.self, forKey: .cost)
        power = try container.decode(Int.self, forKey: .power)
        img = try container.decode(String.self, forKey: .img)
        topDisplay = try container.decode(String.self, forKey: .topDisplay)
        isPublic = try container.decode(String.self, forKey: .isPublic)
    }
}
