//
//  APIEndpoint.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

enum APIEndpoint {
    case searchByQuery(query: String)
    case getLeagueSchedule(entity: EntityInfo, season: Int, yearMonth: String, day: Int?)
    case searchByKeyword(keyword: KeywordInfo)
    case searchByEndpoint(endpoint: String)
    case searchById(season: Int, category: String, date: String?, dataType: String, leagueId: Int, id: String)
    
    case fetchTrendingKeywords
    case fetchLeagueKeywords
    
    var defaultHTTPMethod: String {
        switch self {
        case .searchByQuery, .searchByEndpoint, .fetchTrendingKeywords, .searchById, .fetchLeagueKeywords:
            return "GET"
        case .getLeagueSchedule, .searchByKeyword:
            return "POST"
        }
    }
    
    func url(isTest: Bool = true) -> URL? {
        var components = URLComponents()
//        components.scheme = APIConfiguration.localscheme
//        components.host = APIConfiguration.localhost
//        components.port = APIConfiguration.localport
        components.scheme = APIConfiguration.scheme
        components.host = APIConfiguration.host
        
        switch self {
        case .searchByQuery(let query):
            components.path = "/search"
            components.queryItems = [
                URLQueryItem(name: "query", value: query)
            ]
            
        case .getLeagueSchedule(_, let season, let yearMonth, let day):
            components.path = "/search/schedule"
            
            var items: [URLQueryItem] = [
              URLQueryItem(name: "season", value: String(season)),
              URLQueryItem(name: "yearMonth", value: yearMonth)
            ]

            if let day {
              items.append(URLQueryItem(name: "day", value: String(day)))
            }

            components.queryItems = items
            
        case .searchByKeyword(let keyword):
            components.path = "/search/keyword"
            
        case .searchByEndpoint(let endpoint):
            components.path = "/search/...."
            components.queryItems = [
                URLQueryItem(name: "endpoint", value: endpoint)
            ]
            
        case .searchById(let season, let category, let date, let dataType, let leagueId, let id):
            components.path = "/search/id"
            
            var queryItems = [
                URLQueryItem(name: "season", value: String(season)),
                URLQueryItem(name: "category", value: category),
                URLQueryItem(name: "dataType", value: dataType),
                URLQueryItem(name: "leagueId", value: String(leagueId)),
                URLQueryItem(name: "id", value: id)
            ]
            
            if let date = date {
                queryItems.append(URLQueryItem(name: "date", value: date.replacingOccurrences(of: "+", with: "%2B")))
            }
            
            components.percentEncodedQueryItems = queryItems
            
        case .fetchTrendingKeywords:
            components.path = "/keywords/trending"
            
        case .fetchLeagueKeywords:
            components.path = "/keywords/league"
        }
        
        return components.url
    }
    
    var httpBody: Data? {
        switch self {
        case .searchByQuery, .searchByEndpoint, .fetchTrendingKeywords, .searchById, .fetchLeagueKeywords:
            return nil
        case .searchByKeyword(let keyword):
            // NOTE: nil is excluded
            return try? JSONEncoder().encode(keyword)
        case .getLeagueSchedule(let entity, _, _, _):
            return try? JSONEncoder().encode(entity)
        }
    }
}
