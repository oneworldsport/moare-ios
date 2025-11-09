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
            // 401이면서 "리프레시 가능한" 인증오류면 토큰 재발급 후 1회 재시도
            if let apiErr = error as? APIHTTPError, apiErr.isRefreshableAuthError {
                do {
                    print("getting new token with refresh token...")
                    _ = try await TokenRefresher.shared.refreshedAccessToken()
                } catch {
                    print("failed refreshing token. Deleting tokens...")
                    // token 갱신 실패 시 기존 토큰 삭제
                    clearTokens()
                    throw URLError(.userAuthenticationRequired)
                }
                
                print("trying again...")
                return try await send(endpoint: endpoint) // 새 토큰으로 1회 재시도
            }
            
            // TODO: 다른 401은 안걸리게 처리 필요
//            if isSessionInvalidating(error) {
//                print("Other errors to delete tokens. Deleting tokens...")
//                clearTokens()
//                throw URLError(.userAuthenticationRequired)
//            }
            
            throw error
        }
    }
    
    private func send<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        guard let request = RequestBuilder.buildRequest(endpoint: endpoint) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        guard (200..<300).contains(http.statusCode) else {
            let envelope = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data)
            let body = envelope?.error
            
            throw APIHTTPError(
                status: http.statusCode,
                apiCode: body?.code,
                message: body?.message,
                details: body?.details,
                headers: http.allHeaderFields
            )
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func isSessionInvalidating(_ error: Error) -> Bool {
        guard let e = error as? APIHTTPError else { return false }
        
        switch e.status {
        case 401:
            // 리프레시 가능한 401은 위에서 처리. 나머지 401은 세션 무효
            return !e.isRefreshableAuthError
        case 403:
            // 비활성 사용자 / 권한 없음 등
            return true
        case 400:
            // 일반 폼/비즈니스 유효성 오류는 세션 유지
            // (예: OTP_INVALID, OTP_EXPIRED 등은 세션 무효화 아님)
            return false
        default:
            // 410, 429, 404, 5xx 등은 세션 유지(로그인과 무관)
            return false
        }
    }
    
    private func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
    }
}
