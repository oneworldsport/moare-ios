//
//  MoatRequestModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatCreateRequest: Encodable {
    let content: String
    let sportType: [String]?
    let parentMoatId: String?
}

struct MoatUpdateRequest: Encodable {
    let content: String?
    let sportType: [String]?
}

struct MoatListRequest: Encodable {
    let sportType: [String]?
    let parentMoatId: String?
    var limit: Int = 10
//    let nextToken
}
