//
//  MypageStruct.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/04/19.
//

import Foundation
// 회원정보
struct userInfoResponse: Codable {
    let status: Int?
    let message: String?
    let result: userResponseResult?
    enum CodingKeys: CodingKey {
        case status, message, result
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        result = (try? values.decode(userResponseResult.self, forKey: .result)) ?? nil
    }
}
struct userResponseResult : Codable {
    let idx: Int
    let email: String
    let nickname: String
    let profilePath: String
    let isPremium: Int
    let agreeWithMarketing: Int
    let createdAt: String
    let loginMethod: String
}
