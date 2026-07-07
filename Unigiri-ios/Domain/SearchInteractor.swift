import Foundation

class SearchInteractor {
    private let useCase: GetSearchResultUseCase

    init(useCase: GetSearchResultUseCase) {
        self.useCase = useCase
    }

    func fetchSamples() async throws -> SearchResultModel {
        try await useCase.execute()
    }
}
