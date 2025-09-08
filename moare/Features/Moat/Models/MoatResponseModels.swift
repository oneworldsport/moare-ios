//
//  MoatResponseModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatResponse: Decodable {
    let moatId: String
    let userId: String
    let content: String
    let sportType: [String]
    let parentMoatId: String?
    let targetType: String
    let createdAt: String // TODO: python에서는 datetime인데 확인해보기
    let updatedAt: String?
    let fireCount: Int
    let commentCount: Int
}

struct MoatListResponse: Decodable {
    let items: [MoatResponse]
//    let nextToken: 
}
