//
//  SignRequestModels.swift
//  moare
//
//  Created by 최지혜 on 8/19/25.
//

import Foundation

struct StartAuthRequest: Encodable {
    let id: String
    let method: AuthMethod
}

enum AuthMethod: String, Encodable, Equatable {
    case email = "email"
    case phoneNumber = "phone_number"
}

struct ConfirmAuthRequest: Encodable {
    let id: String
    let otp: String
    let session: String
}

struct SignUpInitiateRequest: Encodable {
    let id: String
    let method: AuthMethod
}

struct SignUpVerificationRequest: Encodable {
    let id: String
    let otp: String
}

struct SignUpCompleteRequest: Encodable {
    let id: String
    let method: AuthMethod
    let profile: UserProfileCreateRequest
}

struct UserProfileCreateRequest: Encodable {
    let userHandle: String
    let profileImageUrl: String? = nil
    let bio: String? = nil
    let sportsInterests: [String]
}

struct UserHandleReserveRequest: Encodable {
    let userHandle: String
}
