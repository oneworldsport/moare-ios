//
//  SearchClient.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/6/24.
//

import Foundation

struct SearchClient {
    private let session = URLSession.shared
    private let apiClient = APIClient()
    
    func fetchDataByQuery(query: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchByQuery(query: query), testQuery: query)
//        return String(decoding: data, as: UTF8.self)
    }
    
    func fetchDataByKeyword(keyword: KeywordInfo) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchByKeyword(keyword: keyword))
    }
    
    func fetchLeagueSchedule(entity: EntityInfo, season: Int?, yearMonth: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .getLeagueSchedule(entity: entity, season: season ?? CalendarUtil.currentYear, yearMonth: yearMonth))
    }
    
    func fetchById(season: Int?, category: String, date: String? = nil, dataType:String, leagueId: Int, id: String) async throws -> DataModel {
        return try await apiClient.fetchData(endpoint: .searchById(season: season ?? CalendarUtil.currentYear, category: category, date: date, dataType: dataType, leagueId: leagueId, id: id))
    }
    
    func fetchFromJson(viewForTest: SportDisplayType) async throws -> DataModel {
        let filePath: String
        
        switch viewForTest {
        case .fbPlayerInfo:
            filePath = "football_player_info"
        case .fbPlayerStats:
            filePath = "football_player_stats"
        case .fbPlayerStandings:
            filePath = "football_player_standings"
        case .fbTeamInfo:
            filePath = "football_team_info"
        case .fbTeamStats:
            filePath = "football_team_stats"
        case .fbTeamStandings:
            filePath = "football_team_standings"
        case .fbLeagueSchedule:
//            filePath = "football_league_schedule"
            filePath = "football_team_schedule"
        case .fbGameStats:
            filePath = "football_game_stats"
        case .nbaPlayerInfo:
            filePath = "nba_player_info"
        case .nbaPlayerStats:
            filePath = "nba_player_stats"
        case .nbaPlayerStandings:
            filePath = "nba_player_standings"
        case .nbaTeamInfo:
            filePath = "nba_team_info"
        case .nbaTeamStats:
            filePath = "nba_team_stats"
        case .nbaTeamStandings:
            filePath = "nba_team_standings"
        case .nbaTeamSchedule:
            filePath = "nba_team_schedule"
        case .nbaLeagueSchedule:
            filePath = "nba_league_schedule"
        case .nbaGameStats:
            filePath = "nba_game_stats"
        case .nbaLeagueTournament:
            filePath = "nba_league_tournament"
        case .kboPlayerInfo:
            filePath = "kbo_player_info"
        case .kboPlayerStats:
            filePath = "kbo_player_stats"
        case .kboPlayerStandings:
            filePath = "kbo_player_standings"
        case .kboTeamInfo:
            filePath = "kbo_team_info"
        case .kboTeamStats:
            filePath = "kbo_team_stats"
        case .kboTeamStandings:
            filePath = "kbo_team_standings"
        case .kboLeagueSchedule:
            filePath = "kbo_league_schedule"
//            filePath = "kbo_team_schedule"
        case .kboGameStats:
            filePath = "kbo_game_stats"
        case .mlbPlayerInfo:
            filePath = "mlb_player_info"
        case .mlbPlayerStats:
            filePath = "mlb_player_stats"
        case .mlbPlayerStandings:
            filePath = "mlb_player_standings"
        case .mlbTeamInfo:
            filePath = "mlb_team_info"
        case .mlbTeamStats:
            filePath = "mlb_team_stats"
        case .mlbTeamStandings:
            filePath = "mlb_team_standings"
        case .mlbLeagueSchedule:
            filePath = "mlb_league_schedule"
//            filePath = "mlb_team_schedule"
        case .mlbGameStats:
            filePath = "mlb_game_stats"
        default:
            filePath = "football_player_info"
        }

        guard let url = Bundle.main.url(forResource: filePath, withExtension: "json") else {
            print("Error: File not found")
                throw URLError(.fileDoesNotExist)
            }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let dataModel = try decoder.decode(DataModel.self, from: data)
        
        return dataModel
    }
}
 
