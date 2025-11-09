//
//  APIErrorModels.swift
//  moare
//
//  Created by Mohwa Yoon on 11/7/25.
//

struct APIErrorEnvelope: Decodable {
    let error: APIErrorBody
}

struct APIErrorBody: Decodable, Equatable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct APIHTTPError: Error {
    let status: Int
    let apiCode: String?
    let message: String?
    let details: [String: String]?
    let headers: [AnyHashable: Any]

    // 401이면서 "리프레시 가능한" 인증오류
    var isRefreshableAuthError: Bool {
        guard status == 401 else { return false }
        
        if let code = apiCode?.uppercased() {
            return code == "TOKEN_EXPIRED"
        } else {
            return false
        }
    }
}
