//
//  MoatClient.swift
//  moare
//
//  Created by Mohwa Yoon on 9/7/25.
//

struct MoatClient {
    private let apiClient = APIClient()
    
    func createMoat(body: MoatCreateRequest) async throws -> MoatResponse {
        return try await apiClient.fetchData(endpoint: .createMoat(body: body))
    }
    
    func updateMoat(moatId: String, body: MoatUpdateRequest) async throws -> MoatResponse {
        return try await apiClient.fetchData(endpoint: .updateMoat(moatId: moatId, body: body))
    }
    
    func deleteMoat(moatId: String) async throws -> MessageResponse {
        return try await apiClient.fetchData(endpoint: .deleteMoat(moatId: moatId))
    }
    
    // TODO: fetch라는 단어가 여기에 더 맞을까 아니면 APIEndpoint에서 사용하는게 더 맞을까?
    func fetchMoatDetail(moatId: String) async throws -> MoatDetailResponse {
        return try await apiClient.fetchData(endpoint: .getMoatDetail(moatId: moatId))
    }
    
    func fetchTrendingMoats(body: MoatListRequest) async throws -> MoatListResponse {
        return try await apiClient.fetchData(endpoint: .getTrendingMoats(body: body))
    }
    
    func fetchMoatsByHashtags(body: MoatListRequest) async throws -> MoatListResponse {
        return try await apiClient.fetchData(endpoint: .getMoatsByHashtag(body: body))
    }
    
    func fetchUserMoats(body: MoatListRequest) async throws -> MoatListResponse {
        return try await apiClient.fetchData(endpoint: .getUserMoats(body: body))
    }
    
    func createFire(body: FireCreateRequest) async throws -> FireResponse {
        return try await apiClient.fetchData(endpoint: .createFire(body: body))
    }
    
    func deleteFire(moatId: String) async throws -> MessageResponse {
        return try await apiClient.fetchData(endpoint: .deleteFire(moatId: moatId))
    }
    
    func checkFire(moatId: String) async throws -> Bool {
        return try await apiClient.fetchData(endpoint: .checkFire(moatId: moatId))
    }
    
    func createReport(body: ReportCreateRequest) async throws -> SimpleResponse {
        return try await apiClient.fetchData(endpoint: .createReport(body: body))
    }
}
