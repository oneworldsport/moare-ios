//
//  MoatResponseModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatResponse: Decodable, Equatable {
    let moatId: String
    let userId: String
    let userHandle: String
    let profileImageUrl: String?
    let content: String
    let sportTags: [String]
    let parentMoatId: String?
    let moatType: String
    let createdAt: String // TODO: python에서는 datetime인데 확인해보기
    let updatedAt: String?
    var fireCount: Int
    let commentCount: Int
    var isFired: Bool
}

struct MoatDetailResponse: Decodable, Equatable {
    var moat: MoatResponse
    var commentListResponse: MoatListResponse?
}

struct MoatListResponse: Decodable, Equatable {
    var moats: [MoatResponse]
    let nextToken: [String: String]?
}

struct FireResponse: Decodable, Equatable {
    let targetId: String
    let userId: String
    let targetType: String
    let createdAt: String // TODO: python에서는 datetime인데 확인해보기
}

struct MessageResponse: Decodable, Equatable {
    let message: String
}
