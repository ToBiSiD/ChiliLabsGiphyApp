import Foundation
import Combine

protocol APILoaderService {
    func fetchGifs(with offset: Int, contentType: ContentType) -> AnyPublisher<GiphyResponse, Error>
    func searchGifs(for query: String, with offset: Int, contentType: ContentType) -> AnyPublisher<GiphyResponse, Error>
}

final class GiphyLoaderService: APILoaderService {
    private let networkLoader: NetworkLoadService = .init()
    
    func fetchGifs(with offset: Int, contentType: ContentType) -> AnyPublisher<GiphyResponse, Error> {
        let params: [GiphyLinkParams: String] = [.offset: "\(offset)"]
        let url = LinkBuilder.buildURL(endpoint: .trendings, contentType: contentType, queryParams: params)
        return fetchData(form: url)
    }
    
    func searchGifs(for query: String, with offset: Int, contentType: ContentType) -> AnyPublisher<GiphyResponse, Error> {
        let params: [GiphyLinkParams: String] = [
            .query: query,
            .offset: "\(offset)"
        ]
        let url = LinkBuilder.buildURL(endpoint: .search, contentType: contentType, queryParams: params)
        
        return fetchData(form: url, usingCache: true)
    }
    
    private func fetchData(form url: URL?, usingCache: Bool = false) -> AnyPublisher<GiphyResponse, Error> {
        networkLoader.fetchData(using: url, cacheResult: usingCache)
            .eraseToAnyPublisher()
    }
}
