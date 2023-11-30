

import Foundation

// 회원가입 - 이메일 인증
struct emailVerifyResponse: Codable {
    let status: Int?
    let statusCode: Int?
    let message: String?
    let result: emailVerifyCode?
    
    enum CodingKeys: CodingKey {
        case status, message, result, statusCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        result = (try? values.decode(emailVerifyCode.self, forKey: .result)) ?? nil
    }
}
struct emailVerifyCode : Codable {
    let signupVerifyToken: String?
}

// 회원가입 - 가입
struct registerResponse: Codable {
    let status: Int?
    let statusCode: Int?
    let message: String?
    let result: registerResponseResult?
    
    enum CodingKeys: CodingKey {
        case status, message, result, statusCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        result = (try? values.decode(registerResponseResult.self, forKey: .result)) ?? nil
    }
}
struct registerResponseResult : Codable {
    let idx: String?
}


// 로그인
struct loginResponse: Codable {
    let status: Int?
    let statusCode: Int?
    let message: String?
    let result: loginResponseResult?
    enum CodingKeys: CodingKey {
        case status, message, result, statusCode
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        result = (try? values.decode(loginResponseResult.self, forKey: .result)) ?? nil
    }
}
struct loginResponseResult : Codable {
    let idx: Int?
    let accessToken: String?
    let refreshToken: String?
}

// 회원정보
struct userInfoResponse: Codable {
    let status: Int?
    let statusCode: Int?
    let message: String?
    let errorCode: String?
    let result: userResponseResult?
    
    enum CodingKeys: CodingKey {
        case status, message, errorCode, result, statusCode
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
        statusCode = (try? values.decode(Int.self, forKey: .statusCode)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        errorCode = (try? values.decode(String.self, forKey: .errorCode)) ?? nil
        result = (try? values.decode(userResponseResult.self, forKey: .result)) ?? nil
    }
}
struct userResponseResult : Codable {
    let idx: Int?
    let email: String?
    let nickname: String?
    let profilePath: String?
    let isPremium: Bool?
    let agreeWithMarketing: Bool?
    let createdAt: String?
    let loginMethod: String?
}
