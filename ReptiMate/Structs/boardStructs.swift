//
//  boardStructs.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/11/08.
//
import Foundation

struct AuctionInfoResponse: Codable {
    let result: AuctionInfo?
    let message: String?
    let status: Int?
    enum CodingKeys: CodingKey {
        case result, message, status
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = (try? values.decode(AuctionInfo.self, forKey: .result)) ?? nil
        message = (try? values.decode(String.self, forKey: .message)) ?? nil
        status = (try? values.decode(Int.self, forKey: .status)) ?? nil
    }
}
struct AuctionInfo: Codable {
    let UserInfo: AuctionUserInfoStructs?
    let boardAuction: AuctionBoardInfoStructs?
    let category: String?
    let commentCnt: Int?
    let description: String?
    let idx: Int?
    let images: [AuctionImageData]?
    let liveStream: AuctionLiveStreamStructs?
    let title: String?
    let userIdx: Int?
    let view: Int?
    let writeDate: String?
    enum CodingKeys: CodingKey {
        case UserInfo, boardAuction, category, commentCnt, description, idx, images, liveStream, title, userIdx, view, writeDate
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        UserInfo = (try? values.decode(AuctionUserInfoStructs.self, forKey: .UserInfo)) ?? nil
        boardAuction = (try? values.decode(AuctionBoardInfoStructs.self, forKey: .boardAuction)) ?? nil
        category = (try? values.decode(String.self, forKey: .category)) ?? nil
        commentCnt = (try? values.decode(Int.self, forKey: .commentCnt)) ?? nil
        description = (try? values.decode(String.self, forKey: .description)) ?? nil
        idx = (try? values.decode(Int.self, forKey: .idx)) ?? nil
        images = (try? values.decode([AuctionImageData].self, forKey: .images)) ?? nil
        liveStream = (try? values.decode(AuctionLiveStreamStructs.self, forKey: .liveStream)) ?? nil
        title = (try? values.decode(String.self, forKey: .title)) ?? nil
        userIdx = (try? values.decode(Int.self, forKey: .userIdx)) ?? nil
        view = (try? values.decode(Int.self, forKey: .view)) ?? nil
        writeDate = (try? values.decode(String.self, forKey: .writeDate)) ?? nil
    }
}
struct AuctionUserInfoStructs: Codable {
    let idx: Int?
    let nickname: String?
    let profilePath: String?
}
struct AuctionBoardInfoStructs: Codable {
    let alertTime : String?
    let birthDate : String?
    let boardIdx : Int?
    let buyPrice : Int?
    let createdAt:String?
    let currentPrice:String?
    let deletedAt :String?
    let endTime : String?
    let extensionRule : Int?
    let extensionTime : String?
    let gender : String?
    let idx : Int?
    let pattern : String?
    let size : String?
    let startPrice : Int?
    let state : String?
    let streamKey : String?
    let unit : Int?
    let updatedAt : String?
    let variety : String?
}
struct AuctionImageDataArray: Codable {
    let images: [AuctionImageData]
}
struct AuctionImageData: Codable {
    let idx: Int?
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let boardIdx: Int?
    let category: String?
    let mediaSequence: Int?
    let path: String?
    let coverImgPath:String?
    enum CodingKeys: String, CodingKey {
        case idx,createdAt,updatedAt,deletedAt,boardIdx,category,mediaSequence,path,coverImgPath
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        idx = (try? values.decode(Int.self, forKey: .idx)) ?? nil
        createdAt = (try? values.decode(String.self, forKey: .createdAt)) ?? nil
        updatedAt = (try? values.decode(String.self, forKey: .updatedAt)) ?? nil
        deletedAt = (try? values.decode(String.self, forKey: .deletedAt)) ?? nil
        boardIdx = (try? values.decode(Int.self, forKey: .boardIdx)) ?? nil
        category = (try? values.decode(String.self, forKey: .category)) ?? nil
        mediaSequence = (try? values.decode(Int.self, forKey: .mediaSequence)) ?? nil
        path = (try? values.decode(String.self, forKey: .path)) ?? nil
        coverImgPath = (try? values.decode(String.self, forKey: .coverImgPath)) ?? nil
    }
}
struct AuctionLiveStreamStructs: Codable {
    let boardIdx:Int?
    let createdAt:String?
    let deletedAt:String?
    let endTime:String?
    let idx:Int?
    let startTime:String?
    let state:Int?
    let streamKey:String?
    let updatedAt:String?
}




