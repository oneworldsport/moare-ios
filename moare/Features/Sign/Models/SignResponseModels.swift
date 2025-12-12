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
    let userId: String
}

struct AuthSessionResponse: Decodable {
    let session: String
}

struct SimpleResponse: Decodable {
    let success: Bool
    let message: String
}

struct BootstrapSessionResponse: Decodable {
    let userId: String
}

enum TermStatus: String, Decodable {
    case active = "ACTIVE"
    case deprecated = "DEPRECATED"
}

enum TermType: String, Codable {
    case privacy = "PRIVACY"
    case service = "SERVICE"
}

struct TermsResponse: Decodable {
    let isRequired: Bool
    let status: TermStatus
    let termType: TermType
    let title: String
    let url: String
    let version: String
}

struct TermKey: Hashable {
    let termType: TermType
    let version: String
}

extension TermsResponse {
    var selfKey: TermKey { .init(termType: termType, version: version) }
}
