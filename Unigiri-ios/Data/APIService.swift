import Foundation

class APIService {
    private let baseURL = "https://search.zutomayocard.net/"
    private let bearerToken = "6d23b47b1bbbbc6c7ca1830c9f5f1a2ac04935aa2ed32e787ac2ef11d3a94685"

    func searchCards(request: SearchRequest) async throws -> SearchResultResponse {
        let url = URL(string: baseURL + "indexes/zutomayocard_cards/search")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(SearchResultResponse.self, from: data)
    }
}
