//
//  SignClient.swift
//  moare
//
//  Created by 최지혜 on 8/20/25.
//

import Foundation

struct SignClient {
    private let apiClient = APIClient()
    
    func bootstrapSession() async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .bootstrapSession)
    }
    
    func startLoginAuth(body: StartAuthRequest) async throws -> AuthSessionResponse {
        return try await apiClient.fetchData(endpoint: .startLoginAuth(body: body))
    }
    
    func confirmLoginAuth(body: ConfirmAuthRequest) async throws -> AuthTokenResponse {
        return try await apiClient.fetchData(endpoint: .confirmLoginAuth(body: body))
    }
    
    func initiateSignUp(body: SignUpInitiateRequest) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .initiateSignUp(body: body))
    }
    
    func verifySignUpOtp(body: SignUpVerificationRequest) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .verifySignUpOtp(body: body))
    }
    
    func completeSignUp(body: SignUpCompleteRequest) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .completeSignUp(body: body))
    }
    
    func checkNickname(nickname: String) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .checkNickname(nickname: nickname))
    }
    
    func reserveNickname(nickname: String) async throws -> SimpleResponse {
        let body = NicknameReserveRequest(nickname: nickname)
        
        return try await apiClient.fetchData(endpoint: .reserveNickname(body: body))
    }
}
