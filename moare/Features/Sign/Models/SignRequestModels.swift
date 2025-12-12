//
//  SignRequestModels.swift
//  moare
//
//  Created by 최지혜 on 8/19/25.
//

import Foundation

struct StartAuthRequest: Encodable {
    let loginId: String
    let method: AuthMethod
}

enum AuthMethod: String, Encodable, Equatable {
    case email = "EMAIL"
    case phoneNumber = "PHONE_NUMBER"
}

struct ConfirmAuthRequest: Encodable {
    let loginId: String
    let otp: String
    let session: String
}

struct SignUpInitiateRequest: Encodable {
    let loginId: String
    let method: AuthMethod
}

struct SignUpVerificationRequest: Encodable {
    let sessionId: String
    let otp: String
}

struct SignUpCompleteRequest: Encodable {
    let sessionId: String
    let loginId: String
    let method: AuthMethod
    let profile: UserProfileCreateRequest
}

struct UserProfileCreateRequest: Encodable {
    let userHandle: String
    let profileImageUrl: String? = nil
    let bio: String? = nil
    let sportsInterests: [String]
    let termsAgreements: [TermsAgreementRequest]
}

struct UserHandleReserveRequest: Encodable {
    let signupSessionId: String?
    let userHandle: String
}

struct TermsAgreementRequest: Encodable {
    let termType: TermType
    let version: String
    let isAgreed: Bool
}
