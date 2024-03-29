import Foundation

struct APIConstants {
    static let limit: Int = 15
    static let baseLink: String = "https://api.giphy.com/v1/"
    static let key: String = "DooTZyR0AN7E5oqCLOtGZp8QwV3VmpGM"
}

enum Endpoints: String {
    case trendings = "/trending"
    case search = "/search"
}

enum ContentType: String {
    case gif = "gifs"
    case stiker = "stickers"
    
    var title: String {
        switch self {
        case .gif: "GIFS"
        case .stiker: "STIKERS"
        }
    }
}

enum GiphyLinkParams: String {
    case query = "q"
    case apiKey = "api_key"
    case limit = "limit"
    case offset = "offset"
    case rating = "rating"
}

struct LinkBuilder {
    static func buildURL(endpoint: Endpoints, contentType: ContentType, queryParams: [GiphyLinkParams: String] = [:]) -> URL? {
        var components = URLComponents(string: APIConstants.baseLink + contentType.rawValue + endpoint.rawValue)
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: GiphyLinkParams.apiKey.rawValue, value: APIConstants.key))
        queryItems.append(URLQueryItem(name: GiphyLinkParams.limit.rawValue, value: "\(APIConstants.limit)"))
        
        for (param, value) in queryParams {
            queryItems.append(URLQueryItem(name: param.rawValue, value: value))
        }
        
        components?.queryItems = queryItems
        
        return components?.url
    }
}
