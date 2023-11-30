//
//  Structs.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/04/13.
//

import Foundation



struct SimpleResponse<T: Codable>: Codable {
    let status: Int?
    let statusCode: Int?
    let message: String?
    let errorCode: String?
    let result: T?
    
    enum CodingKeys: CodingKey {
        case status, message, errorCode, result, statusCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        errorCode = (try? values.decode(String.self, forKey: .errorCode)) ?? nil
        result = (try? values.decode(T.self, forKey: .result)) ?? nil
    }
}

struct messageResponse: Codable {
    let status: Int?
    let statusCode: Int?
    let message: String?
    let errorCode: String?
    let result: String?
    let error: String?
    
    enum CodingKeys: CodingKey {
        case status, message, errorCode, result, error, statusCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        errorCode = (try? values.decode(String.self, forKey: .errorCode)) ?? nil
        result = (try? values.decode(String.self, forKey: .result)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        error = (try? values.decode(String.self, forKey: .error)) ?? nil
    }
}

