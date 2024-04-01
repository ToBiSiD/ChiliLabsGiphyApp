import XCTest
import Combine
import AVFoundation

@testable import ChiliLabsTestTask

final class GiphyVideoCacheServiceTests: XCTestCase {
    var videoCacheService: VideoCacheService!
    let validURLString = "https://example.com/validVideo.mp4"
    let invalidURLString = "sg/invalid/ag"
    
    override func setUp() {
        super.setUp()
        videoCacheService = GiphyVideoCacheService()
    }
    
    override func tearDown() {
        videoCacheService = nil
        super.tearDown()
    }
    
    
    func testLoadVideoFromValidURL() {
        let expectation = XCTestExpectation(description: "Loading video from valid URL")
        
        let cancellable = videoCacheService.loadVideo(from: validURLString)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Loading video failed with error: \(error)")
                }
            }, receiveValue: { asset in
                XCTAssertNotNil(asset)
            })
        
        wait(for: [expectation], timeout: 5.0)
        cancellable.cancel()
    }
    
    func testLoadVideoFromInvalidURL() {
        let expectation = XCTestExpectation(description: "Loading video from invalid URL")
        
        var receivedError: Error?
        
        let cancellable = videoCacheService.loadVideo(from: invalidURLString)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Loading video from invalid URL should fail")
                case .failure(let error):
                    receivedError = error
                    expectation.fulfill()
                }
            }, receiveValue: { asset in
                XCTAssertNil(asset)
            })
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(receivedError)
        XCTAssertTrue(receivedError is NetworkError)
        XCTAssertEqual(receivedError as? NetworkError, NetworkError.invalidLink)
        
        cancellable.cancel()
    }
    
    func testVideoCaching() {
        let expectation = XCTestExpectation(description: "Caching video")
        var asset1: AVURLAsset?
        var asset2: AVURLAsset?
        var cancellables = Set<AnyCancellable>()

        videoCacheService.loadVideo(from: validURLString)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Failed to load video 1: \(error)")
                case .finished:
                    self.videoCacheService.loadVideo(from: self.validURLString)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .failure(let error):
                                XCTFail("Failed to load video 2: \(error)")
                            case .finished:
                                XCTAssertEqual(asset1, asset2)
                                expectation.fulfill()
                            }
                        }, receiveValue: { asset in
                            asset2 = asset
                        })
                        .store(in: &cancellables)
                }
            }, receiveValue: { asset in
                asset1 = asset
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }
}
