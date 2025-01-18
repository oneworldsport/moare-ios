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
    
    func fetchLeagueSchedule(leagueId: String, yearMonth: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .getLeagueSchedule(leagueId: leagueId, yearMonth: yearMonth))
    }
    
    func fetchDataByKeyword(keyword: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchByKeyword(keyword: keyword), testQuery: keyword)
    }
    
    func fetchHotKeywords() async throws -> [String] {
        return try await apiClient.fetchData(endpoint: .hotKeyword, testQuery: "hot keyword")
    }
}
 
