//
//  APIClient.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct APIClient {
    func fetchData<T: Decodable>(endpoint: APIEndpoint, testQuery: String = "") async throws -> T {
        do {
            return try await send(endpoint: endpoint)
        } catch {
            // 에러가 401 토큰 만료면 리프레시 후 1회 재시도
            if let apiErr = error as? APIHTTPError, apiErr.code == 401, apiErr.isTokenExpired {
                print("getting new token with refresh token...")
                _ = try await TokenRefresher.shared.refreshedAccessToken()
                print("trying again...")
                return try await send(endpoint: endpoint) // 새 토큰으로 1회 재시도
            }
            throw error
        }
        
//        var data: Data? = nil
//        
//        let filePath: String
//        
//        if testQuery == "손흥민" {
//            filePath = "football_player_info"
//        } else if testQuery == "손흥민 기록" {
//            filePath = "football_player_stats"
//        } else if testQuery == "손흥민 순위" {
//            filePath = "football_player_standings"
//        } else if testQuery == "토트넘" {
//            filePath = "football_team_info"
//        } else if testQuery == "토트넘 기록" {
//            filePath = "football_team_stats"
//        } else if testQuery == "토트넘 순위" {
//            filePath = "football_team_standings"
//        } else if testQuery == "프리미어리그 일정" {
//            filePath = "football_league_schedule"
//        } else if testQuery == "토트넘 일정" {
//            filePath = "football_team_schedule"
//        } else if testQuery == "토트넘 뉴캐슬 기록" {
//            filePath = "football_game_stats"
//        } else {
//            filePath = "football_player_info"
//        }
        
//        let url = Bundle.main.url(forResource: filePath, withExtension: "json")
//        data = try Data(contentsOf: url!)
//        return try JSONDecoder().decode(T.self, from: data!)
    }
    
    private func send<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        guard let request = RequestBuilder.buildRequest(endpoint: endpoint) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        guard (200..<300).contains(http.statusCode) else {
            let msg = (try? JSONDecoder().decode(ErrorResponse.self, from: data))?.detail
            
            throw APIHTTPError(code: http.statusCode, message: msg)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// TODO: 다른곳으로 이동
struct ErrorResponse: Decodable {
    let detail: String?
}

struct APIHTTPError: Error {
    let code: Int
    let message: String?
    var isTokenExpired: Bool {
        code == 401 && (message?.lowercased().contains("token expired") == true)
    }
}
