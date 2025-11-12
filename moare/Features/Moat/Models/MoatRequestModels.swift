//
//  MoatRequestModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatCreateRequest: Encodable {
    let content: String
    let sportTags: [String]
    let parentMoatId: String?
    
    init(
        content: String,
        sportTags: [String],
        parentMoatId: String? = nil
    ) {
        self.content = content
        self.sportTags = sportTags
        self.parentMoatId = parentMoatId
    }
}

struct MoatUpdateRequest: Encodable {
    let content: String?
    let sportTags: [String]?
}

struct MoatListRequest: Encodable {
    let sportTags: [String]?
    let parentMoatId: String?
    let limit: Int
    let nextToken: [String: String]?
    
    init(
        sportTags: [String]? = nil,
        parentMoatId: String? = nil,
        limit: Int = 10,
        nextToken: [String : String]? = nil
    ) {
        self.sportTags = sportTags
        self.parentMoatId = parentMoatId
        self.limit = limit
        self.nextToken = nextToken
    }
}

struct FireCreateRequest: Encodable {
    let targetId: String
    let targetType: TargetType
    
    init(
        targetId: String,
        targetType: TargetType
    ) {
        self.targetId = targetId
        self.targetType = targetType
    }
}

enum TargetType: String, Encodable, Equatable {
    case moat = "moat"
    case comment = "comment"
}

struct FireCancelRequest: Encodable {
    let targetId: String
    let targetType: TargetType
    
    init(
        targetId: String,
        targetType: TargetType
    ) {
        self.targetId = targetId
        self.targetType = targetType
    }
}
