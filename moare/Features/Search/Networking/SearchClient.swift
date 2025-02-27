//
//  SearchClient.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/6/24.
//

import Foundation

struct SearchClient {
    private let session = URLSession.shared
    private let apiClient = APIClient()
    
    func fetchDataByQuery(query: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchByQuery(query: query), testQuery: query)
//        return String(decoding: data, as: UTF8.self)
    }
    
    func fetchDataByKeyword(keyword: TrendingKeyword) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchByKeyword(keyword: keyword))
    }
    
    func fetchLeagueSchedule(leagueId: Int, yearMonth: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .getLeagueSchedule(leagueId: leagueId, yearMonth: yearMonth))
    }
    
    func fetchGameInfo(category: String, date: String, leagueId: Int, fixtureId: Int) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .fetchGameInfo(category: category, date: date, leagueId: leagueId, fixtureId: fixtureId))
    }
}
 
