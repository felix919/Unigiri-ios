import Foundation

struct SearchRequest: Encodable {
    let q: String
    let limit: Int
    let filter: String
}
