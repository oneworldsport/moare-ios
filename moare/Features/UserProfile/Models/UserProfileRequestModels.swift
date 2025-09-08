//
//  UserProfile.swift
//  moare
//
//  Created by Mohwa Yoon on 9/9/25.
//

struct UserProfileUpdateRequest: Encodable {
    let nickname: String?
    let profileImageUrl: String?
    let bio: String?
    let sportsInterests: [String]?
}
