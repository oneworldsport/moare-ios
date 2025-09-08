//
//  MoatRequestModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatCreateRequest: Encodable {
    let content: String
    let sportType: [String]
    let parentMoatId: String?
    
    init(
        content: String,
        sportType: [String],
        parentMoatId: String? = nil
    ) {
        self.content = content
        self.sportType = sportType
        self.parentMoatId = parentMoatId
    }
}

struct MoatUpdateRequest: Encodable {
    let content: String?
    let sportType: [String]?
}

struct MoatListRequest: Encodable {
    let sportType: String?
    let parentMoatId: String?
    let limit: Int
    let nextToken: [String: String]?
    
    init(
        sportType: String? = nil,
        parentMoatId: String? = nil,
        limit: Int = 10,
        nextToken: [String : String]? = nil
    ) {
        self.sportType = sportType
        self.parentMoatId = parentMoatId
        self.limit = limit
        self.nextToken = nextToken
    }
}
