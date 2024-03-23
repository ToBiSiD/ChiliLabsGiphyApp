import Foundation
import Combine

typealias NetworkService = DataHandler & NetworkHandler

protocol NetworkLoadProtocol: NetworkService {
    func fetchData<T: Decodable>(using url: URL?, cacheResult: Bool) -> AnyPublisher<T, Error>
}

final class NetworkLoadService: NetworkLoadProtocol {
    private(set) var decoder: JSONDecoder
    private(set) var encoder: JSONEncoder
    
    private(set) var loadedData: [String: Decodable] = [:]
    
    init() {
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    func fetchData<T: Decodable>(using url: URL?, cacheResult: Bool) -> AnyPublisher<T, Error> {
        guard let url = url else {
            return Fail(error: NetworkError.invalidLink).eraseToAnyPublisher()
        }
        
        if let cachedData = loadedData[url.absoluteString] as? T {
            return Just(cachedData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                try self.tryHandleResponse(response, data: data)
            }
            .handleEvents(receiveOutput: { [weak self] decodedData in
                if cacheResult {
                    self?.loadedData[url.absoluteString] = decodedData
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func tryHandleResponse<T: Decodable>(_ response: URLResponse, data: Data) throws -> T {
        try tryCheckResponse(response: response)
        let decodeData: T = try decodeData(data: data)
        return decodeData
    }
}
