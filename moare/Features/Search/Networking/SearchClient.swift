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
    
    func fetchDataByKeyword(keyword: KeywordInfo) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchByKeyword(keyword: keyword))
    }
    
    func fetchLeagueSchedule(entity: EntityInfo, yearMonth: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .getLeagueSchedule(entity: entity, yearMonth: yearMonth))
    }
    
    func fetchById(category: String, date: String? = nil, dataType:String, leagueId: Int, id: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchById(category: category, date: date, dataType: dataType, leagueId: leagueId, id: id))
    }
}
 
