//
//  RequestBuilder.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct RequestBuilder {
    static func buildRequest(
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
        
        if method == "POST" {
            request.httpBody = endpoint.httpBody
        }
        
        return request
    }
}
