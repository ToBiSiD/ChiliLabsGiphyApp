import Foundation
import Combine

final class GiphyLoaderService {
    private let decoder: JSONDecoder = .init()
    
    init() {
        
    }
    
    func fetchGifs() -> AnyPublisher<GiphyResponse, Error> {
        guard let url = LinkBuilder.buildURL(endpoint: .trendings, contentType: .gif) else {
            return Fail(error: GIFError.invalidURL).eraseToAnyPublisher()
        }
        
        DebugLogger.printLog(url.absoluteString, place: .service("\(self)"), type: .action)
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: GiphyResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func searchGifs() -> AnyPublisher<GiphyResponse, Error> {
        guard let url = URL(string: "") else {
            return Fail(error: GIFError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: GiphyResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
