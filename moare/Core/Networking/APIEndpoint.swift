//
//  APIEndpoint.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

enum APIEndpoint {
    case searchByQuery(query: String)
    case getLeagueSchedule(entity: EntityInfo, season: Int, yearMonth: String)
    case searchByKeyword(keyword: KeywordInfo)
    case searchByEndpoint(endpoint: String)
    case searchById(season: Int, category: String, date: String?, dataType: String, leagueId: Int, id: String)
    
    case fetchTrendingKeywords
    
    case startLoginAuth(body: StartAuthRequest)
    case confirmLoginAuth(body: ConfirmAuthRequest)
    case initiateSignUp(body: SignUpInitiateRequest)
    case verifySignUpOtp(body: SignUpVerificationRequest)
    case completeSignUp(body: SignUpCompleteRequest)
    case checkNickname(nickname: String)
    case reserveNickname(body: NicknameReserveRequest)
    
    var defaultHTTPMethod: String {
        switch self {
        case .searchByQuery, .searchByEndpoint, .fetchTrendingKeywords, .searchById, .checkNickname:
            return "GET"
        case .getLeagueSchedule, .searchByKeyword, .startLoginAuth, .confirmLoginAuth, .initiateSignUp, .verifySignUpOtp, .completeSignUp:
            return "POST"
        case .reserveNickname:
            return "PUT"
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
            
        case .getLeagueSchedule(_, let season, let yearMonth):
            components.path = "/search/schedule"
            components.queryItems = [
                URLQueryItem(name: "season", value: String(season)),
                URLQueryItem(name: "yearMonth", value: yearMonth)
            ]
            
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
            
        case .startLoginAuth(let body):
            components.path = "/auth/login/start"
            
        case .confirmLoginAuth(let body):
            components.path = "/auth/login/confirm"
            
        case .initiateSignUp(let body):
            components.path = "/auth/signup/initiate"
            
        case .verifySignUpOtp(let body):
            components.path = "/auth/signup/verify"
            
        case .completeSignUp(let body):
            components.path = "/auth/signup/complete"
            
        case .checkNickname(let nickname):
            components.path = "/auth/nickname/check"
            components.queryItems = [
                URLQueryItem(name: "nickname", value: nickname)
            ]
            
        case .reserveNickname(let body):
            components.path = "/auth/nickname/reserve"
        }
        
        return components.url
    }
    
    var httpBody: Data? {
        switch self {
        case .searchByQuery, .searchByEndpoint, .fetchTrendingKeywords, .searchById, .checkNickname:
            return nil
        case .searchByKeyword(let keyword):
            // NOTE: nil is excluded
            return try? JSONEncoder().encode(keyword)
        case .getLeagueSchedule(let entity, _, _):
            return try? JSONEncoder().encode(entity)
        case .startLoginAuth(let body):
            return try? JSONEncoder().encode(body)
        case .confirmLoginAuth(let body):
            return try? JSONEncoder().encode(body)
        case .initiateSignUp(let body):
            return try? JSONEncoder().encode(body)
        case .verifySignUpOtp(let body):
            return try? JSONEncoder().encode(body)
        case .completeSignUp(let body):
            return try? JSONEncoder().encode(body)
        case .reserveNickname(let body):
            return try? JSONEncoder().encode(body)
        }
    }
}
