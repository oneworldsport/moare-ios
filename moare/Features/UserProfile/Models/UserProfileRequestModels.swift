//
//  UserProfile.swift
//  moare
//
//  Created by Mohwa Yoon on 9/9/25.
//

struct UserProfileUpdateRequest: Encodable {
    var userHandle: String? = nil
    var profileImageUrl: String? = nil
    var bio: String? = nil
    var sportsInterests: [String]? = nil
}
