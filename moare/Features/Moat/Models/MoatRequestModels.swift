//
//  MoatRequestModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatCreateRequest: Encodable {
    var content: String
    var sportTags: [String]
    var parentMoatId: String?
    
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
    var content: String? = nil
    var sportTags: [String]? = nil
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
    let targetType: FireTargetType
    
    init(
        targetId: String,
        targetType: FireTargetType
    ) {
        self.targetId = targetId
        self.targetType = targetType
    }
}

enum FireTargetType: String, Encodable, Equatable {
    case moat = "moat"
    case comment = "comment"
}

struct FireCancelRequest: Encodable {
    let targetId: String
    let targetType: FireTargetType
    
    init(
        targetId: String,
        targetType: FireTargetType
    ) {
        self.targetId = targetId
        self.targetType = targetType
    }
}

enum ReportTargetType: String, Encodable, Equatable {
    case moat = "MOAT"
    case user = "USER"
}

enum ReasonCode: String, Encodable, Equatable {
    case other = "OTHER"
}

struct ReportCreateRequest: Encodable {
    let targetType: ReportTargetType
    let targetId: String
    let reasonCode: ReasonCode
    let reasonText: String
}
