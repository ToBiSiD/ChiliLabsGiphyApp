import XCTest
import Combine

@testable import ChiliLabsTestTask

extension GiphyResponse {
    static func createMockResponse(count: Int) -> GiphyResponse {
        let objects = (0..<count).map { _ in GiphyObject.mockGiphy }
        let mockPagination = Pagination(totalCount: 1, count: count, offset: 0)
        return GiphyResponse(data: objects, pagination: mockPagination)
    }
}

final class MockAPILoaderService: APILoaderService {
    var mockResponse: AnyPublisher<GiphyResponse, Error>?
    
    init(mockResponse: AnyPublisher<GiphyResponse, Error>? = nil) {
        self.mockResponse = mockResponse
    }
    
    func setMockResponse(_ mockResponse: AnyPublisher<GiphyResponse, Error>? = nil) {
        self.mockResponse = mockResponse
    }
    
    func fetchGifs(with offset: Int, contentType: ContentType) -> AnyPublisher<GiphyResponse, Error> {
        guard let mockResponse = mockResponse else {
            fatalError("Mock response not set for fetchGifs")
        }
        
        return mockResponse
    }
    
    func searchGifs(for query: String, with offset: Int, contentType: ContentType) -> AnyPublisher<GiphyResponse, Error> {
        guard let mockResponse = mockResponse else {
            fatalError("Mock response not set for searchGifs")
        }
        
        return mockResponse
    }
}

final class GiphyViewModelTests: XCTestCase {
    var viewModel: GiphyViewModel!
    var mockAPIService: MockAPILoaderService!
    
    override func setUp() {
        super.setUp()
        
        let response = Just(GiphyResponse.createMockResponse(count: 1))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        mockAPIService = MockAPILoaderService(mockResponse: response)
        viewModel = GiphyViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    func testFetch() {
        let expectation = XCTestExpectation(description: "Fetching gifs")
        
        let responsePublisher = Just(GiphyResponse.createMockResponse(count: 3))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    
        mockAPIService.setMockResponse(responsePublisher)
        
        _ = viewModel.$dataState
            .sink { state in
                switch state {
                case .loaded, .error:
                    expectation.fulfill()
                default:
                    break
                }
            }
        
        viewModel.fetch()
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(viewModel.gifs.count, 3)
        XCTAssertEqual(viewModel.offset, 0)
    }
    
    func testSearch() {
        let expectation = XCTestExpectation(description: "Searching gifs")
        
        let responsePublisher = Just(GiphyResponse.createMockResponse(count: 5))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    
        mockAPIService.setMockResponse(responsePublisher)
        
        _ = viewModel.$dataState
            .sink { state in
                switch state {
                case .loaded, .error:
                    expectation.fulfill()
                default:
                    break
                }
            }
        
        viewModel.search(for: "test query")
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(viewModel.gifs.count, 5)
        XCTAssertEqual(viewModel.offset, 0)
    }
}
