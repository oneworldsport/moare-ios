//
//  APIEndpoint.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

enum APIEndpoint {
    case searchByQuery(query: String)
    case getLeagueSchedule(leagueId: String, yearMonth: String)
    case searchByKeyword(keyword: String)
    case searchByEndpoint(endpoint: String)
    
    case hotKeyword
    
    var defaultHTTPMethod: String {
        switch self {
        case .searchByQuery, .getLeagueSchedule, .searchByKeyword, .searchByEndpoint, .hotKeyword:
            return "GET"
        }
    }
    
    func url(isTest: Bool = true) -> URL? {
        var components = URLComponents()
        components.scheme = APIConfiguration.scheme
        components.host = APIConfiguration.host
//        components.port = APIConfiguration.localport
        
        switch self {
        case .searchByQuery(let query):
            components.path = "/search"
            components.queryItems = [
                URLQueryItem(name: "query", value: query)
            ]
            
        case .getLeagueSchedule(let leagueId, let yearMonth):
            components.path = "/search/schedule"
            components.queryItems = [
                URLQueryItem(name: "leagueId", value: leagueId),
                URLQueryItem(name: "yearMonth", value: yearMonth)
            ]
            
        case .searchByKeyword(let keyword):
            components.path = "/search/...."
            components.queryItems = [
                URLQueryItem(name: "keyword", value: keyword)
            ]
            
        case .searchByEndpoint(let endpoint):
            components.path = "/search/...."
            components.queryItems = [
                URLQueryItem(name: "endpoint", value: endpoint)
            ]
            
        case .hotKeyword:
            components.path = "//...."
        }
        
        return components.url
    }
}
