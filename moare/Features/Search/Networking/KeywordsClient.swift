//
//  KeywordsClient.swift
//  moare
//
//  Created by Mohwa Yoon on 2/18/25.
//

import Foundation
import ComposableArchitecture

struct KeywordsClient {
    var fetchTrendingKeywords: @Sendable () async throws -> [KeywordInfo]
    var fetchLeagueKeywords: @Sendable () async throws -> LeagueKeywords
}

extension KeywordsClient: DependencyKey {
    static let liveValue = Self(
        fetchTrendingKeywords: {
            try await APIClient().fetchData(endpoint: .fetchTrendingKeywords)
        }, fetchLeagueKeywords: {
            try await APIClient().fetchData(endpoint: .fetchLeagueKeywords)
        }
    )
}
