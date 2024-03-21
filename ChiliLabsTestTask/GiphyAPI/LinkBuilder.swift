import Foundation

enum APIConstants: String {
    case baseLink = "https://api.giphy.com/v1/"
    case key = "DooTZyR0AN7E5oqCLOtGZp8QwV3VmpGM"
}

enum Endpoints: String {
    case trendings = "/trending"
    case search = "/search"
}

enum ContentType: String {
    case gif = "gifs"
    case stiker = "stickers"
}

enum GiphyLinkParams: String {
    case query = "q"
    case apiKey = "api_key"
    case limit = "limit"
    case offset = "offset"
    case rating = "rating"
}

enum GIFError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError
}

struct LinkBuilder {
    static func buildURL(endpoint: Endpoints, contentType: ContentType, queryParams: [GiphyLinkParams: String] = [:]) -> URL? {
        var components = URLComponents(string: APIConstants.baseLink.rawValue + contentType.rawValue + endpoint.rawValue)
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: GiphyLinkParams.apiKey.rawValue, value: APIConstants.key.rawValue))
        queryItems.append(URLQueryItem(name: GiphyLinkParams.limit.rawValue, value: "10"))
        
        for (param, value) in queryParams {
            queryItems.append(URLQueryItem(name: param.rawValue, value: value))
        }
        
        components?.queryItems = queryItems
        
        return components?.url
    }
}
