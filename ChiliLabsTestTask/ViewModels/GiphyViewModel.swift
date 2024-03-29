import Foundation
import Combine

enum DataState {
    case idle
    case loaded
    case error(message: String)
}

final class GiphyViewModel {
    private let apiService: APILoaderService
    
    private(set) var gifs: [GiphyObject] = []
    private(set) var offset = 0
    
    private var cancellables: Set<AnyCancellable> = []
    private var totalCount = 0
    private var contentType: ContentType = .gif
    
    @Published private(set) var dataState: DataState = .idle
    
    init(apiService: APILoaderService) {
        self.apiService = apiService
        
        fetch()
    }
    
    func clearData() {
        gifs.removeAll()
    }
    
    func search(for query: String) {
        offset = 0
        sendRequest(query: query)
    }
    
    func fetch() {
        offset = 0
        sendRequest()
    }
    
    func tryFecthNext() {
        guard offset + APIConstants.limit < totalCount else {
            return
        }
        
        offset += APIConstants.limit
        sendRequest()
    }
    
    func tryChangeContentType(_ newValue: ContentType) {
        if newValue != contentType {
            contentType = newValue
            fetch()
        }
    }
}

private extension GiphyViewModel {
    func sendRequest(query: String? = nil) {
        let requestPublisher: AnyPublisher<GiphyResponse, Error>
        if let query = query {
            requestPublisher = apiService.searchGifs(for: query, with: offset, contentType: contentType)
        } else {
            requestPublisher = apiService.fetchGifs(with: offset, contentType: contentType)
        }
        
        requestPublisher
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] result in
                self?.handleSuccess(result)
            }
            .store(in: &cancellables)
    }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        guard case .failure(let error) = completion else { return }
        
        dataState = .error(message: error.localizedDescription)
        DebugLogger.printLog(error, place: .viewModel("\(self)"), type: .error)
    }
    
    func handleSuccess(_ result: GiphyResponse) {
        guard !result.data.isEmpty else { return }
        
        totalCount = result.pagination.totalCount
        gifs = offset == 0 ? result.data : gifs + result.data
        DebugLogger.printLog(gifs.count, place: .viewModel("\(self)"), type: .success)
        
        dataState = gifs.count == 0 ? .error(message: "Cannot find any giphy") : .loaded
    }
}
