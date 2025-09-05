//
//  SignResponseModels.swift
//  moare
//
//  Created by 최지혜 on 8/19/25.
//

import Foundation

struct AuthResponse: Decodable {
    let type: AuthResponseType
    let message: String
    let data: DynamicCodableValue
}

enum AuthResponseType: String, Decodable, Equatable {
    case success = "SUCCESS"
    case retry = "RETRY"
    case expired = "EXPIRED"
    case limitExceeded = "LIMIT_EXCEEDED"
    case error = "ERROR"
}

struct AuthTokenData: Decodable {
    let idToken: String
    let accessToken: String
    let refreshToken: String
}

struct AuthSessionResponse: Decodable {
    let session: String
}

struct SimpleResponse: Decodable {
    let success: Bool
    let message: String
}

// TODO: confirmLoginAuthResult 를 만든 이유는 안드로이드처럼 confirmLoginAuth 의 결과물로 -> Any? 를 사용하는 방법은 swift에서 권장하지 않는다고 함. enum 이 Type-safe 하고 안정적이라고 함
enum confirmLoginAuthResult {
    case token(AuthTokenData)
    case session(AuthSessionResponse)
    case type(AuthResponseType)
}
