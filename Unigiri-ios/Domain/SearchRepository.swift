import Foundation

protocol SearchRepository {
    func fetchSearchResult() async throws -> SearchResultModel
}
