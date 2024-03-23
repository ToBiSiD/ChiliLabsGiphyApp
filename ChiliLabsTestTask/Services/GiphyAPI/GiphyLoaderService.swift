import Foundation
import Combine

final class GiphyLoaderService {
    private let networkLoader: NetworkLoadService = .init()
    
    func fetchGifs(with  offset: Int = 0) -> AnyPublisher<GiphyResponse, Error> {
        let params: [GiphyLinkParams: String] = [.offset: "\(offset)"]
        let url = LinkBuilder.buildURL(endpoint: .trendings, contentType: .gif, queryParams: params)
        return fetchData(form: url)
    }
    
    func searchGifs(for query: String, with  offset: Int = 0) -> AnyPublisher<GiphyResponse, Error> {
        let params: [GiphyLinkParams: String] = [
            .query: query,
            .offset: "\(offset)"
        ]
        let url = LinkBuilder.buildURL(endpoint: .search, contentType: .gif, queryParams: params)
        
        return fetchData(form: url, usingCache: true)
    }
    
    private func fetchData(form url: URL?, usingCache: Bool = false) -> AnyPublisher<GiphyResponse, Error> {
        networkLoader.fetchData(using: url, cacheResult: usingCache)
            .eraseToAnyPublisher()
    }
}
