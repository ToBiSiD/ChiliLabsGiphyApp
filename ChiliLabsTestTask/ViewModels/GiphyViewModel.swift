//
//  GiphyViewModel.swift
//  ChiliLabsTestTask
//
//  Created by Tobias on 21.03.2024.
//

import Foundation
import Combine

final class GiphyViewModel {
    private let apiService: GiphyLoaderService = .init()
    @Published private(set) var gifs: [GIFObject] = []
    @Published private(set) var errorText: String?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        fetchGifs()
    }
    
    func search(for query: String) {
        apiService.searchGifs()
            .sink { completion in
                switch completion {
                case .finished:
                    self.errorText = nil
                    break
                case .failure(let error):
                    self.errorText = error.localizedDescription
                }
            } receiveValue: { result in
                self.gifs = result.data
            }
            .store(in: &cancellables)
    }
}

private extension GiphyViewModel {
    func fetchGifs() {
        apiService.fetchGifs()
            .sink { completion in
                switch completion {
                case .finished:
                    self.errorText = nil
                    break
                case .failure(let error):
                    self.errorText = error.localizedDescription
                    DebugLogger.printLog(error, place: .viewModel("\(self)"), type: .error)
                }
            } receiveValue: { result in
                self.gifs = result.data
                DebugLogger.printLog(self.gifs.count, place: .viewModel("\(self)"), type: .success)
            }
            .store(in: &cancellables)
    }
}
