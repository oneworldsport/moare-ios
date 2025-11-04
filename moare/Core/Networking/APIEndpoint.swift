//
//  APIEndpoint.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

enum APIEndpoint {
    // search
    case searchByQuery(query: String)
    case getLeagueSchedule(entity: EntityInfo, season: Int, yearMonth: String)
    case searchByKeyword(keyword: KeywordInfo)
    case searchByEndpoint(endpoint: String)
    case searchById(season: Int, category: String, date: String?, dataType: String, leagueId: Int, id: String)
    
    case fetchTrendingKeywords
    
    // sign
    case bootstrapSession
    case startLoginAuth(body: StartAuthRequest)
    case confirmLoginAuth(body: ConfirmAuthRequest)
    case initiateSignUp(body: SignUpInitiateRequest)
    case verifySignUpOtp(body: SignUpVerificationRequest)
    case completeSignUp(body: SignUpCompleteRequest)
    case checkNickname(nickname: String)
    case reserveNickname(body: NicknameReserveRequest)
    
    // moat
    case createMoat(body: MoatCreateRequest)
    case updateMoat(moatId: String, body: MoatUpdateRequest)
    case deleteMoat(moatId: String)
    case getMoatDetail(moatId: String)
    case getTimelineMoats(body: MoatListRequest)
    case getUserMoats(body: MoatListRequest)
    
    // user
    case getUserProfile
    case updateUserProfile(body: UserProfileUpdateRequest)
    
    var defaultHTTPMethod: String {
        switch self {
        case .searchByQuery, .searchByEndpoint, .fetchTrendingKeywords, .searchById, .bootstrapSession, .checkNickname, .getMoatDetail, .getUserProfile:
            return "GET"
        case .getLeagueSchedule, .searchByKeyword, .startLoginAuth, .confirmLoginAuth, .initiateSignUp, .verifySignUpOtp, .completeSignUp,
                .createMoat, .getTimelineMoats, .getUserMoats:
            return "POST"
        case .reserveNickname:
            return "PUT"
        case .updateMoat, .updateUserProfile:
            return "PATCH"
        case .deleteMoat:
            return "DELETE"
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
        // search
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
            
        case .searchByKeyword(_):
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
            
        // sign
        case .bootstrapSession:
            components.path = "/auth/session"
            
        case .startLoginAuth:
            components.path = "/auth/login/start"
            
        case .confirmLoginAuth:
            components.path = "/auth/login/confirm"
            
        case .initiateSignUp:
            components.path = "/auth/signup/initiate"
            
        case .verifySignUpOtp:
            components.path = "/auth/signup/verify"
            
        case .completeSignUp:
            components.path = "/auth/signup/complete"
            
        case .checkNickname(let nickname):
            components.path = "/auth/nickname/check"
            components.queryItems = [
                URLQueryItem(name: "nickname", value: nickname)
            ]
            
        case .reserveNickname:
            components.path = "/auth/nickname/reserve"
            
        // moat
        case .createMoat:
            components.path = "/moats"
            
        case .updateMoat(let moatId, _):
            components.path = "/moats/\(moatId)"
            
        case .deleteMoat(let moatId):
            components.path = "/moats/\(moatId)"
            
        case .getMoatDetail(let moatId):
            components.path = "/moats/\(moatId)"
            
        case .getTimelineMoats:
            components.path = "/moats/timeline"
            
        case .getUserMoats:
            components.path = "/moats/user"
            
        // user
        case .getUserProfile:
            components.path = "/users/me"
            
        case .updateUserProfile(_):
            components.path = "/users/me"
        }
        
        return components.url
    }
    
    var headers: [String: String]? {
        switch self {
        case .bootstrapSession, .createMoat, .updateMoat, .deleteMoat, .getMoatDetail, .getTimelineMoats, .getUserMoats, .getUserProfile, .updateUserProfile:
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                return ["Authorization": "Bearer \(token)"]
            } else {
                return nil
            }
            
        default: return nil

        }
    }
    
    var httpBody: Data? {
        switch self {
        case .bootstrapSession, .searchByQuery, .searchByEndpoint, .fetchTrendingKeywords, .searchById, .checkNickname, .deleteMoat, .getMoatDetail, .getUserProfile:
            return nil
            
        // search
        case .searchByKeyword(let keyword):
            // NOTE: nil is excluded
            return try? JSONEncoder().encode(keyword)
        case .getLeagueSchedule(let entity, _, _):
            return try? JSONEncoder().encode(entity)
            
        // sign
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
            
        // moat
        case .createMoat(let body):
            return try? JSONEncoder().encode(body)
        case .updateMoat(_, let body):
            return try? JSONEncoder().encode(body)
        case .getTimelineMoats(let body):
            return try? JSONEncoder().encode(body)
        case .getUserMoats(let body):
            return try? JSONEncoder().encode(body)
            
        // user
        case .updateUserProfile(let body):
            return try? JSONEncoder().encode(body)
        }
    }
}
