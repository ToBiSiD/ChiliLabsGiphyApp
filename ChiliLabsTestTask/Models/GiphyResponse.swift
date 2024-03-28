import Foundation

struct GiphyResponse: Decodable {
    let data: [GiphyObject]
    let pagination: Pagination
}

struct Pagination: Decodable {
    let totalCount: Int
    let count: Int
    let offset: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case count
        case offset
    }
}

struct GiphyObject: Decodable {
    let id: String
    let type: String
    let title: String
    let rating: String
    let url: String
    let importDate: String
    let trendingDate: String
    let images: Images
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case url
        case rating
        case importDate = "import_datetime"
        case trendingDate = "trending_datetime"
        case images
        case user
    }
}

extension GiphyObject {
    static let mockGiphy: GiphyObject =
        .init(
            id: "11111",
            type: "gif",
            title: "Title test long title test long title test long title test long title test long title test long title test long title test long title test long title test long title test long title test long title test long title test long title test long ",
            rating: "g",
            url: "https://media0.giphy.com/media/vOMInkwuCzy19On48i",
            importDate: "2022-04-20 18:46:14",
            trendingDate: "2022-04-20 18:46:14",
            images: .init(
                fixedWidth: .init(
                    mp4: "https://media0.giphy.com/media/vOMInkwuCzy19On48i/200w.mp4?cid=6a9e8bf2gqgn3y3mme2ae7z01y3hzy40gpi6wn3mujv8j4ke&ep=v1_gifs_trending&rid=200w.mp4&ct=g",
                    height: "200",
                    width: "200"
                )
            ),
            user: .init(
                avatarURL: "https://media1.giphy.com/avatars/franziskahoellbacher/UIvGguYWRcrJ.jpg",
                profileURL: "https://giphy.com/franziskahoellbacher/",
                displayName: "Franziska Höllbacher",
                description: "Hi! I‘m Franzi.\r\nI‘m an illustrator and author with a serious cat-obsession", 
                instagramURL: "https://instagram.com/franziskahoellbacher",
                websiteURL: "https://franziskahoellbacher.de")
        )
}

struct Images: Decodable {
    let fixedWidth: FixedSize
    
    enum CodingKeys: String, CodingKey {
        case fixedWidth = "fixed_width"
    }
}

struct FixedSize: Decodable {
    let mp4: String?
    let height: String
    let width: String
    
    func getLink() -> String {
        if let mp4 = mp4 {
            return mp4
        } else {
            return ""
        }
    }
    
    func getSize() -> (width: Int, height: Int) {
        (width: self.width.toInt(), height: self.height.toInt())
    }
}


struct User: Decodable {
    let avatarURL: String
    let profileURL: String
    let displayName: String
    let description: String
    let instagramURL: String
    let websiteURL: String

    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
        case profileURL = "profile_url"
        case displayName = "display_name"
        case description
        case instagramURL = "instagram_url"
        case websiteURL = "website_url"
    }
}

