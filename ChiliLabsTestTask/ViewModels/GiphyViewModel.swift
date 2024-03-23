import Foundation
import Combine

enum DataState {
    case idle
    case loaded
    case error(message: String)
}

final class GiphyViewModel {
    private let apiService: GiphyLoaderService = .init()
    
    private(set) var gifs: [GiphyObject] = []
    private(set) var offset = 0
    
    private var cancellables: Set<AnyCancellable> = []
    private var totalCount = 0
    
    @Published private(set) var dataState: DataState = .idle
    
    init() {
        fetch()
    }
    
    func clearData() {
        gifs.removeAll()
    }
    
    func search(for query: String) {
        offset = 0
        sendSearchRequest(query)
    }
    
    func fetch() {
        offset = 0
        sendFetchRequest()
    }
    
    func tryFecthNext() {
        guard offset + APIConstants.limit < totalCount else {
            return
        }
        
        offset += APIConstants.limit
        sendFetchRequest()
    }
}

private extension GiphyViewModel {
    func sendFetchRequest() {
        apiService.fetchGifs(with: offset)
            .sink { completion in
                self.handleCompletion(completion)
            } receiveValue: { result in
                self.handleSuccess(result)
            }
            .store(in: &cancellables)
    }
    
    func sendSearchRequest(_ query: String) {
        apiService.searchGifs(for: query, with: offset)
            .sink { completion in
                self.handleCompletion(completion)
            } receiveValue: { result in
                self.handleSuccess(result)
            }
            .store(in: &cancellables)
    }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            dataState = .error(message: error.localizedDescription)
            DebugLogger.printLog(error, place: .viewModel("\(self)"), type: .error)
        }
    }
    
    func handleSuccess(_ result: GiphyResponse) {
        guard !result.data.isEmpty else {
            dataState = .error(message: "Cannot find any giphy")
            return
        }
        
        totalCount = result.pagination.totalCount
        
        if offset == 0 {
            gifs = result.data
        } else {
            gifs += result.data
        }
        
        DebugLogger.printLog(gifs.count, place: .viewModel("\(self)"), type: .success)
        dataState = .loaded
        dataState = .error(message: "Errrorororor")
    }
}
