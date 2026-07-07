import Foundation

class SearchRepositoryImpl: SearchRepository {
    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    func fetchSearchResult() async throws -> SearchResultModel {
        let response = try await api.searchCards(
            request: SearchRequest(
                q: "",
                limit: 999,
                filter: "public != \"非公開\""
            )
        )

        return SearchResultModel(
            hits: response.hits.map { hit in
                ZutocaModel(
                    id: hit.id,
                    pack: hit.pack,
                    title: hit.title,
                    songs: hit.songs,
                    illustrator: hit.illustrator,
                    rare: hit.rare,
                    type: hit.type,
                    cardType: hit.cardType,
                    clock: hit.clock,
                    nightAttack: hit.nightAttack,
                    noonAttack: hit.noonAttack,
                    effect: hit.effect,
                    cost: hit.cost,
                    power: hit.power,
                    img: hit.img,
                    topDisplay: hit.topDisplay,
                    isPublic: hit.isPublic
                )
            },
            query: response.query,
            processingTimeMs: response.processingTimeMs,
            limit: response.limit,
            offset: response.offset,
            estimatedTotalHits: response.estimatedTotalHits,
            requestUid: response.requestUid
        )
    }
}
