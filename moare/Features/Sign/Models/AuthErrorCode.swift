//
//  AuthErrorCode.swift
//  moare
//
//  Created by Mohwa Yoon on 11/7/25.
//

enum AuthErrorCode: String, Decodable {
    case otpInvalid = "OTP_INVALID"
    case otpExpired = "OTP_EXPIRED"
    case otpAttemptLimitExceeded = "OTP_ATTEMPT_LIMIT_EXCEEDED"
    case userAlreadyExists = "USER_ALREADY_EXISTS"
    case userNotFound = "USER_NOT_FOUND"
    case unknown
}

extension AuthErrorCode {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = AuthErrorCode(rawValue: rawValue) ?? .unknown
    }
}
