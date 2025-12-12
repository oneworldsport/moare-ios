//
//  SignClient.swift
//  moare
//
//  Created by 최지혜 on 8/20/25.
//

import Foundation

struct SignClient {
    private let apiClient = APIClient()
    
    func bootstrapSession() async throws -> BootstrapSessionResponse {
        return try await apiClient.fetchData(endpoint: .bootstrapSession)
    }
    
    func startLoginAuth(body: StartAuthRequest) async throws -> AuthSessionResponse {
        return try await apiClient.fetchData(endpoint: .startLoginAuth(body: body))
    }
    
    func confirmLoginAuth(body: ConfirmAuthRequest) async throws -> AuthTokenResponse {
        return try await apiClient.fetchData(endpoint: .confirmLoginAuth(body: body))
    }
    
    func initiateSignUp(body: SignUpInitiateRequest) async throws -> SignUpInitiateResponse {
        return try await apiClient.fetchData(endpoint: .initiateSignUp(body: body))
    }
    
    func verifySignUpOtp(body: SignUpVerificationRequest) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .verifySignUpOtp(body: body))
    }
    
    func completeSignUp(body: SignUpCompleteRequest) async throws -> AuthTokenResponse {
        return try await apiClient.fetchData(endpoint: .completeSignUp(body: body))
    }
    
    func checkUserHandle(userHandle: String, signupSessionId: String? = nil) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .checkUserHandle(userHandle: userHandle, signupSessionId: signupSessionId))
    }
    
    func reserveUserHandle(body: UserHandleReserveRequest) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .reserveUserHandle(body: body))
    }
    
    func fetchTermsList() async throws -> [TermsResponse] {
        return try await apiClient.fetchData(endpoint: .getTerms(context: "signup"))
    }
}
