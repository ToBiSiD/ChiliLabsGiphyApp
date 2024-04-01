import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidLink
    case invalidRequest
    case invalidResponse
    case notFound
    case badRequest
    case requestIsExist
    case requestError(errorCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidLink:
            return NSLocalizedString("Invalid link.", comment: "")
        case .invalidRequest:
            return NSLocalizedString("Invalid request", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response.", comment: "")
        case .notFound:
            return NSLocalizedString("Not found.", comment: "")
        case .badRequest:
            return NSLocalizedString("Bad request.", comment: "")
        case .requestIsExist :
            return NSLocalizedString("Request is Exist", comment: "")
        case .requestError(let errorCode):
            return NSLocalizedString("Request error with code \(errorCode).", comment: "")
        }
    }
}
