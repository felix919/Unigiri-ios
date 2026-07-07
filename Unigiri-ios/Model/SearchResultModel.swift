import Foundation

struct SearchResultModel {
    let hits: [ZutocaModel]
    let query: String
    let processingTimeMs: Int
    let limit: Int
    let offset: Int
    let estimatedTotalHits: Int
    let requestUid: String

    static let empty = SearchResultModel(
        hits: [],
        query: "",
        processingTimeMs: 0,
        limit: 0,
        offset: 0,
        estimatedTotalHits: 0,
        requestUid: ""
    )
}
