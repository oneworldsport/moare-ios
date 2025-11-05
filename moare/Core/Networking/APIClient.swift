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
            if let apiErr = error as? APIHTTPError, apiErr.isTokenExpired {
                do {
                    print("getting new token with refresh token...")
                    _ = try await TokenRefresher.shared.refreshedAccessToken()
                } catch {
                    print("failed refreshing token. Deleting tokens...")
                    // token 갱신 실패 시 기존 토큰 삭제
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    
                    throw URLError(.userAuthenticationRequired)
                }
                
                print("trying again...")
                return try await send(endpoint: endpoint) // 새 토큰으로 1회 재시도
            }
            
            if isSessionInvalidating(error) {
                print("Other errors to delete tokens. Deleting tokens...")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                
                throw URLError(.userAuthenticationRequired)
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
    
    func isSessionInvalidating(_ error: Error) -> Bool {
        guard let e = error as? APIHTTPError else { return false }
        // 회복 불가로 보는 케이스들만 엄격히 포함
        switch e.code {
        case 401:
            // 401인데 "만료"가 아니라면 서명 불일치/위조/알 수 없는 토큰 등 -> 세션 무효
            return !e.isTokenExpired
        case 403:
            // 자격은 유효하나 접근권한/상태 문제(사용자 비활성화 등) → 로그인 재유도
            return true
        case 400:
            // 백엔드가 돌려주는 대표 auth 오류 예시
//            if e.awsType == "NotAuthorizedException" { return true }
//            if e.reason == "invalid_grant" { return true } // (주로 refresh 플로우에서)
            return false
        default:
            return false // 429, 5xx, 4xx 일반 유효성 등은 세션 유지
        }
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
