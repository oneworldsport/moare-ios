//
//  KeywordsClient.swift
//  moare
//
//  Created by Mohwa Yoon on 2/18/25.
//

import Foundation

struct KeywordsClient {
    private let apiClient = APIClient()
    
    func fetchTrendingKeywords() async throws -> [KeywordInfo] {
        return try await apiClient.fetchData(endpoint: .fetchTrendingKeywords)
    }
}
