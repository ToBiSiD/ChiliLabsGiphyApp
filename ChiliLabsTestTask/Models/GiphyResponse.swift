//
//  GiphyResponse.swift
//  ChiliLabsTestTask
//
//  Created by Tobias on 21.03.2024.
//

import Foundation

struct GiphyResponse: Decodable {
    let data: [GIFObject]
}

struct GIFObject: Decodable {
    let type: String
    let title: String
    let id: String
    let slug: String
    let url: String
    let bitlyUrl: String
    let embedUrl: String
    let rating: String
    let importDate: String
    let trendingDate: String
    let images: Images
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case id
        case slug
        case url
        case bitlyUrl = "bitly_url"
        case embedUrl = "embed_url"
        case rating
        case importDate = "import_datetime"
        case trendingDate = "trending_datetime"
        case images = "images"
    }
}

struct Images: Codable {
    let original: FixedSize
    
    enum CodingKeys: String, CodingKey {
        case original
    }
}

struct FixedSize: Codable {
    let mp4: String?
    let webp: String?

    enum CodingKeys: String, CodingKey {
        case mp4
        case webp
    }
    
    func getLink() -> String? {
        if let mp4 = mp4 {
            return mp4
        } else if let webp = webp {
            return webp
        } else {
            return nil
        }
    }
}

