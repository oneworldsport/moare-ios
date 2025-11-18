//
//  RequestBuilder.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct RequestBuilder {
    static func buildRequest(endpoint: APIEndpoint) -> URLRequest? {
        let method = endpoint.defaultHTTPMethod
        guard let url = endpoint.url() else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if method == "POST" || method == "PUT" || method == "PATCH" {
            request.httpBody = endpoint.httpBody
        }
        
        return request
    }
}
