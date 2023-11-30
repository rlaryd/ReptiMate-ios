
import Foundation


struct petListResponse: Codable {
    let pageSize: Int?
    let totalCount: Int?
    let totalPage: Int?
    let existsNextPage: Bool
    let items: [petListItem]?
    
    enum CodingKeys: CodingKey {
        case pageSize, totalCount, totalPage, existsNextPage, items
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pageSize = (try? values.decode(Int.self, forKey: .pageSize)) ?? nil
        totalCount = (try? values.decode(Int.self, forKey: .totalCount)) ?? nil
        totalPage = (try? values.decode(Int.self, forKey: .totalPage)) ?? nil
        existsNextPage = try values.decode(Bool.self, forKey: .existsNextPage)
        items = (try? values.decode([petListItem].self, forKey: .items)) ?? nil
    }
}
struct petListItem: Codable {
    let idx: Int?
    let name: String?
    let type: String?
    let gender: String?
    let birthDate: String?
    let adoptionDate: String?
    let weight: Double?
    let imagePath: String?
}

struct petMemoResponse: Codable {
    let pageSize: Int?
    let totalCount: Int?
    let totalPage: Int?
    let existsNextPage: Bool
    let items: [petMemoItem]?
    
    enum CodingKeys: CodingKey {
        case pageSize, totalCount, totalPage, existsNextPage, items
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pageSize = (try? values.decode(Int.self, forKey: .pageSize)) ?? nil
        totalCount = (try? values.decode(Int.self, forKey: .totalCount)) ?? nil
        totalPage = (try? values.decode(Int.self, forKey: .totalPage)) ?? nil
        existsNextPage = try values.decode(Bool.self, forKey: .existsNextPage)
        items = (try? values.decode([petMemoItem].self, forKey: .items)) ?? nil
    }
}
struct petMemoItem: Codable {
    let idx: Int?
    let title: String?
    let content: String?
    let imagePath: String?
    let createdAt: String?
}

struct MemoDetailResponse: Codable {
    let idx: Int?
    let title: String?
    let content: String?
    let images: [petMemoDetailImgItem]?
    let createdAt: String?
    
    enum CodingKeys: CodingKey {
        case idx, title, content, images, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        idx = (try? values.decode(Int.self, forKey: .idx)) ?? nil
        title = (try? values.decode(String.self, forKey: .title)) ?? nil
        content = (try? values.decode(String.self, forKey: .content)) ?? nil
        images = try values.decode([petMemoDetailImgItem].self, forKey: .images)
        createdAt = (try? values.decode(String.self, forKey: .createdAt)) ?? nil
    }
}
struct petMemoDetailImgItem: Codable {
    let idx: Int?
    let imagePath: String?
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let diaryIdx: Int?
}

struct petWeightResponse: Codable {
    let pageSize: Int?
    let totalCount: Int?
    let totalPage: Int?
    let existsNextPage: Bool
    let items: [petWeightDetailItem]?
    
    
    enum CodingKeys: CodingKey {
        case pageSize, totalCount, totalPage, existsNextPage, items
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pageSize = (try? values.decode(Int.self, forKey: .pageSize)) ?? nil
        totalCount = (try? values.decode(Int.self, forKey: .totalCount)) ?? nil
        totalPage = (try? values.decode(Int.self, forKey: .totalPage)) ?? nil
        existsNextPage = try values.decode(Bool.self, forKey: .existsNextPage)
        items = (try? values.decode([petWeightDetailItem].self, forKey: .items)) ?? nil
    }
}

struct petWeightDetailItem: Codable {
    let idx: Int?
    let weight: Float?
    var date: String?
    var weightChange: Float?
}

struct petWeightYearResponse: Codable {
    let status: Int?
    let statusCode: Int?
    let message: String?
    let result: [petWeightDetailItemYear]?
    enum CodingKeys: CodingKey {
        case status, message, result, statusCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        result = (try? values.decode([petWeightDetailItemYear].self, forKey: .result)) ?? nil
    }
}
struct petWeightDetailItemYear: Codable {
    let month: Int?
    let average: Float?
}
