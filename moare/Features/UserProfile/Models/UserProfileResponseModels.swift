//
//  UserResponseModels.swift
//  moare
//
//  Created by Mohwa Yoon on 9/9/25.
//

struct UserProfileResponse: Decodable {
    let userId: String
    let nickname: String
    let profileImageUrl: String?
    let bio: String?
    let sportsInterests: [String]?
    let joinedAt: String
}

struct UserProfileWithMoatsResponse: Decodable {
    let userProfile: UserProfileResponse
    let moats: MoatListResponse?
}

struct UserSummaryResponse: Decodable {
    let userId: String
    let nickname: String
    let profileImageUrl: String?
}
