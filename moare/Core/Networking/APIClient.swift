//
//  APIClient.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/9/24.
//

import Foundation

struct APIClient {
    func fetchData<T: Decodable>(endpoint: APIEndpoint, testQuery: String = "") async throws -> T {
        guard let request = RequestBuilder.buildRequest(endpoint: endpoint, method: endpoint.defaultHTTPMethod) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw NSError(domain: "NetworkError", code: 1, userInfo: nil)
            throw URLError(.badServerResponse)
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
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
