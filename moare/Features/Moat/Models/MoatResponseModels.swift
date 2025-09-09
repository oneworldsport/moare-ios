//
//  MoatResponseModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatResponse: Decodable, Equatable {
    let moatId: String
    let userId: String
    let nickname: String
    let profileImageUrl: String?
    let content: String
    let sportType: [String]
    let parentMoatId: String?
    let targetType: String
    let createdAt: String // TODO: python에서는 datetime인데 확인해보기
    let updatedAt: String?
    let fireCount: Int
    let commentCount: Int
}

struct MoatDetailResponse: Decodable, Equatable {
    let moat: MoatResponse
    let comments: MoatListResponse?
}

// TODO: 이름 변경
struct MoatListResponse: Decodable, Equatable {
    let items: [MoatResponse]
    let nextToken: [String: String]?
}
