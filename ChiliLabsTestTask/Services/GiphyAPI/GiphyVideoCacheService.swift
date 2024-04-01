import Foundation
import AVKit
import Combine

protocol VideoCacheService {
    func loadVideo(from urlString: String) -> AnyPublisher<AVURLAsset?, Error>
}

final class GiphyVideoCacheService: VideoCacheService {
    private(set) var cached: [String: AVURLAsset] = [:]
    private let cacheQueue = DispatchQueue(label: "cachingQueue")
    
    func loadVideo(from urlString: String) -> AnyPublisher<AVURLAsset?, Error> {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return Fail(error: NetworkError.invalidLink).eraseToAnyPublisher()
        }
        
        if let cachedVideo = cached[urlString] {
            return Just(cachedVideo)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Future<AVURLAsset?, Error> { promise in
            let asset = AVURLAsset(url: url)
            
            self.cacheQueue.async {
                self.cached[urlString] = asset
            }
            
            promise(.success(asset))
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
