//
//  APIEndpoint.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

enum APIEndpoint {
    case searchByQuery(query: String)
    case getLeagueSchedule(leagueId: Int, yearMonth: String)
    case searchByKeyword(keyword: TrendingKeyword)
    case searchByEndpoint(endpoint: String)
    case fetchGameInfo(category: String, date: String, leagueId: Int, fixtureId: Int)
    
    case fetchTrendingKeywords
    
    var defaultHTTPMethod: String {
        switch self {
        case .searchByQuery, .getLeagueSchedule, .searchByEndpoint, .fetchTrendingKeywords, .fetchGameInfo:
            return "GET"
        case .searchByKeyword:
            return "POST"
        }
    }
    
    func url(isTest: Bool = true) -> URL? {
        var components = URLComponents()
        components.scheme = APIConfiguration.localscheme
        components.host = APIConfiguration.localhost
        components.port = APIConfiguration.localport
//        components.scheme = APIConfiguration.scheme
//        components.host = APIConfiguration.host
        
        switch self {
        case .searchByQuery(let query):
            components.path = "/search"
            components.queryItems = [
                URLQueryItem(name: "query", value: query)
            ]
            
        case .getLeagueSchedule(let leagueId, let yearMonth):
            components.path = "/search/schedule"
            components.queryItems = [
                URLQueryItem(name: "leagueId", value: String(leagueId)),
                URLQueryItem(name: "yearMonth", value: yearMonth)
            ]
            
        case .searchByKeyword(let keyword):
            components.path = "/search/keyword"
            
        case .searchByEndpoint(let endpoint):
            components.path = "/search/...."
            components.queryItems = [
                URLQueryItem(name: "endpoint", value: endpoint)
            ]
            
        case .fetchGameInfo(let category, let date, let leagueId, let fixtureId):
            components.path = "/search/game"
            components.queryItems = [
                URLQueryItem(name: "category", value: category),
                URLQueryItem(name: "date", value: date),
                URLQueryItem(name: "leagueId", value: String(leagueId)),
                URLQueryItem(name: "fixtureId", value: String(fixtureId))
            ]
            
        case .fetchTrendingKeywords:
            components.path = "/keywords/trending"
        }
        
        return components.url
    }
    
    var httpBody: Data? {
        switch self {
        case .searchByQuery, .getLeagueSchedule, .searchByEndpoint, .fetchTrendingKeywords, .fetchGameInfo:
            return nil
        case .searchByKeyword(let keyword):
            return try? JSONEncoder().encode(keyword)
        }
    }
}
