import Foundation

protocol NetworkHandler {
    func tryCheckResponse(response: URLResponse) throws
    func mapResponseStatus(statusCode: Int) throws
}

extension NetworkHandler {
    func tryCheckResponse(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        try mapResponseStatus(statusCode: httpResponse.statusCode)
    }
    
    func mapResponseStatus(statusCode: Int) throws {
        switch statusCode {
        case 200..<300:
            return
        case 400:
            throw NetworkError.badRequest
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.requestError(errorCode: statusCode)
        }
    }
}
