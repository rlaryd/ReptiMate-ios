//
//  ScheduleStructs.swift


import Foundation


struct ScheduleListResponse: Codable {
    let pageSize: Int?
    let totalCount: String?
    let totalPage: Int?
    let existsNextPage: Bool?
    let items: [ScheduleStructs]?
    enum CodingKeys: CodingKey {
        case pageSize, totalCount, totalPage, existsNextPage, items
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pageSize = (try? values.decode(Int.self, forKey: .pageSize)) ?? nil
        totalCount = (try? values.decode(String.self, forKey: .totalCount)) ?? nil
        totalPage = (try? values.decode(Int.self, forKey: .totalPage)) ?? nil
        existsNextPage = (try? values.decode(Bool.self, forKey: .existsNextPage)) ?? nil
        items = (try? values.decode([ScheduleStructs].self, forKey: .items)) ?? nil
    }
}
struct ScheduleStructs: Codable {
    let idx: Int?
    let title: String?
    let memo: String?
    let alarmTime: String?
    let repeatDay: String?
    let type: String?
    let date: String?
}
struct CalendarListResponse: Codable {
    let status: Int?
    let message: String?
    let errorCode: String?
    let statusCode: Int?
    let result: [CalendarStructs]?
    enum CodingKeys: CodingKey {
        case status, message, errorCode, result, statusCode
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        errorCode = (try? values.decode(String.self, forKey: .errorCode)) ?? nil
        result = (try? values.decode([CalendarStructs].self, forKey: .result)) ?? nil
    }
}
struct CalendarStructs: Codable {
    let idx: Int?
    let title: String?
    let memo: String?
    let alarmTime: String?
    let repeatDay: String?
    let type: String?
    let date: String?
}
