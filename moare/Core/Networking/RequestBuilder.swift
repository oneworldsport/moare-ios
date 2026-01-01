//
//  RequestBuilder.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

class RequestBuilder {
    func buildRequest(
        endpoint: APIEndpoint,
        method: String,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> URLRequest? {
        guard let url = endpoint.url() else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
//        headers?.forEach { key, value in
//            request.setValue($1, forHTTPHeaderField: $0)
//            request.setValue(value, forHTTPHeaderField: key)
//        }
//        request.httpBody = body
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        commonHeaders().forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if method == "POST" {
            request.httpBody = endpoint.httpBody
        }
        
        return request
    }
    
    private func commonHeaders() -> [String: String] {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"

        return [
            "X-Platform": "ios",
            "X-App-Version": version,
//            "X-App-Build": build
        ]
    }
}
