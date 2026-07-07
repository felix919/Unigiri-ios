import Foundation

class GetSearchResultUseCase {
    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute() async throws -> SearchResultModel {
        try await repository.fetchSearchResult()
    }
}
