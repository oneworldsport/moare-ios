//
//  SignResponseModels.swift
//  moare
//
//  Created by 최지혜 on 8/19/25.
//

import Foundation

struct AuthTokenResponse: Decodable {
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
