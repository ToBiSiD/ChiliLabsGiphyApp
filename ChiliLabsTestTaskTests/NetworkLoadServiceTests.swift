import XCTest
import Combine

@testable import ChiliLabsTestTask

struct TestData: Codable, Equatable {
    let id: Int
    let description: String
    let subInfo: [String]
}

extension TestData {
    static let mockData = TestData(id: 123, description: "description for test data", subInfo: ["1", "45", "true", "name"])
}

final class NetworkLoadServiceTests: XCTestCase {
    var networkLoadService: NetworkLoadService!
    var cancellables = Set<AnyCancellable>()
    let validURL = "https://example.com/data.json"
    
    override func setUp() {
        super.setUp()
        networkLoadService = NetworkLoadService()
    }
    
    override func tearDown() {
        networkLoadService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Test Cases
    func testFetchDataSuccess() {
        let expectation = XCTestExpectation(description: "Fetching data successfully")
        let testData = TestData.mockData // Define your test data model
        
        // Mock URL and data
        let testURL = URL(string: "https://example.com/data.json")!
        let jsonData = try! JSONEncoder().encode(testData)
        
        // Define a mock URLSession
        class MockURLSession: URLSession {
            var mockData: Data?
            var mockResponse: URLResponse?
            var mockError: Error?
            
            override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                let task = MockURLSessionDataTask()
                task.completionHandler = { [weak self] in
                    completionHandler(self?.mockData, self?.mockResponse, self?.mockError)
                }
                return task
            }
        }
        
        let mockSession = MockURLSession() // Instantiate the mock URLSession
        mockSession.mockData = jsonData
        mockSession.mockResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        networkLoadService.fetchData(using: testURL, cacheResult: false, session: mockSession)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to fetch data: \(error.localizedDescription)")
                }
            }, receiveValue: { (receivedData: TestData) in
                XCTAssertEqual(receivedData, testData)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
