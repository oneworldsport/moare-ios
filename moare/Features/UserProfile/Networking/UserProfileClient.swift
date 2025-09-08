//
//  UserProfileClient.swift
//  moare
//
//  Created by Mohwa Yoon on 9/9/25.
//

struct UserProfileClient {
    private let apiClient = APIClient()
    
    func fetchUserProfile() async throws -> UserProfileResponse {
        return try await apiClient.fetchData(endpoint: .getUserProfile)
    }
    
    func updateUserProfile(body: UserProfileUpdateRequest) async throws -> UserProfileResponse {
        return try await apiClient.fetchData(endpoint: .updateUserProfile(body: body))
    }
}
