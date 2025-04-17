//
//  DataModel.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 4/11/24.
//

import Foundation

// TODO: 이렇게 구조 만든 이유 설명
struct DataModel: Decodable {
    let dataType: String
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let data: SportDecodableModel
}

struct EntityInfo: Codable, Equatable {
    let entityId: Int
    let entityName: String
    let category: String
    let entityType: String
    let leagueId: Int
    let teamId: Int?
    let playerId: Int?
}

struct Keyword: Codable, Equatable {
    let keyword: String
    let id: String
    let priority: Int
}

enum SportDecodableModel: Equatable {
    // football
    case fbPlayerInfo(FBPlayerInfoResponseModel, FBPlayerInfoDisplayModel)
    case fbPlayerStats(FBPlayerInfoResponseModel, FBPlayerStatsDisplayModel)
    case fbPlayerStandings(FBPlayerStandingsResponseModel, FBPlayerStandingsDisplayModel)
    case fbTeamInfo(FBTeamInfoResponseModel, FBTeamInfoDisplayModel)
    case fbTeamStats(FBTeamInfoResponseModel, FBTeamStatsDisplayModel)
    case fbTeamStandings(FBTeamStandingsResponseModel, FBTeamStandingsDisplayModel)
    case fbTeamSchedule(FBGameScheduleResponseModel, FBTeamScheduleDisplayModel)
    case fbLeagueSchedule(FBGameScheduleResponseModel, FBLeagueScheduleDisplayModel)
    case fbGameStats(FBGameStatsReponseModel, FBGameStatsDisplayModel)
    
    // nba
    case nbaPlayerInfo(NBAPlayerInfoResponseModel, NBAPlayerInfoDisplayModel)
    case nbaPlayerStats(NBAPlayerInfoResponseModel, NBAPlayerStatsDisplayModel)
    case nbaPlayerStandings(NBAPlayerStandingsResponseModel, NBAPlayerStandingsDisplayModel)
    case nbaTeamInfo(NBATeamInfoResponseModel, NBATeamInfoDisplayModel)
    case nbaTeamStats(NBATeamInfoResponseModel, NBATeamStatsDisplayModel)
    case nbaTeamStandings(NBATeamStandingsResponseModel, NBATeamStandingsDisplayModel)
    case nbaTeamSchedule(NBAGameScheduleResponseModel, NBATeamScheduleDisplayModel)
    case nbaLeagueSchedule(NBAGameScheduleResponseModel, NBALeagueScheduleDisplayModel)
    case nbaGameStats(NBAGameStatsReponseModel, NBAGameStatsDisplayModel)
    
    case unknown
    
    static func == (lhs: SportDecodableModel, rhs: SportDecodableModel) -> Bool {
        switch (lhs, rhs) {
        case (.fbPlayerInfo, .fbPlayerInfo),
            (.fbPlayerStats, .fbPlayerStats),
            (.fbPlayerStandings, .fbPlayerStandings),
            (.fbTeamInfo, .fbTeamInfo),
            (.fbTeamStats, .fbTeamStats),
            (.fbTeamStandings, .fbTeamStandings),
            (.fbTeamSchedule, .fbTeamSchedule),
            (.fbLeagueSchedule, .fbLeagueSchedule),
            (.fbGameStats, .fbGameStats),
            (.nbaPlayerInfo, .nbaPlayerInfo),
            (.nbaPlayerStats, .nbaPlayerStats),
            (.nbaPlayerStandings, .nbaPlayerStandings),
            (.nbaTeamInfo, .nbaTeamInfo),
            (.nbaTeamStats, .nbaTeamStats),
            (.nbaTeamStandings, .nbaTeamStandings),
            (.nbaTeamSchedule, .nbaTeamSchedule),
            (.nbaLeagueSchedule, .nbaLeagueSchedule),
            (.nbaGameStats, .nbaGameStats),
            (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}

extension DataModel {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = try container.decode(String.self, forKey: .dataType)
        self.keywords = try container.decode([Keyword].self, forKey: .keywords)
        self.entityInfo = try container.decode([EntityInfo].self, forKey: .entityInfo)
        
        let modelConverter = ModelConverter(keywords: keywords, entityInfo: entityInfo)
        
        switch dataType {
        // football
        case let dataType where dataType == "football_player_info":
            let responseModel = try container.decode(FBPlayerInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbPlayerInfoConverter(response: responseModel)
                self.data = .fbPlayerInfo(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_player_stats":
            let responseModel = try container.decode(FBPlayerInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbPlayerStatsConverter(response: responseModel)
                self.data = .fbPlayerStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_player_standings":
            let responseModel = try container.decode(FBPlayerStandingsResponseModel.self, forKey: .data)
            
            if responseModel.standings.isEmpty {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbPlayerStandingsConverter(response: responseModel)
                self.data = .fbPlayerStandings(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_info":
            let responseModel = try container.decode(FBTeamInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbTeamInfoConverter(response: responseModel)
                self.data = .fbTeamInfo(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_stats":
            let responseModel = try container.decode(FBTeamInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbTeamStatsConverter(response: responseModel)
                self.data = .fbTeamStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_standings":
            let responseModel = try container.decode(FBTeamStandingsResponseModel.self, forKey: .data)
            
            if responseModel.standings.isEmpty {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbTeamStandingsConverter(response: responseModel)
                self.data = .fbTeamStandings(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_schedule":
            let responseModel = try container.decode(FBGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.fbTeamScheduleConverter(response: responseModel)
            self.data = .fbTeamSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "football_league_schedule":
            let responseModel = try container.decode(FBGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.fbLeagueScheduleConverter(response: responseModel)
            self.data = .fbLeagueSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "football_game_stats":
            let responseModel = try container.decode(FBGameStatsReponseModel.self, forKey: .data)
            
            if responseModel.game == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbGameStatsConverter(response: responseModel)
                self.data = .fbGameStats(responseModel, displayModel)
            }
            
        // basketball
        case let dataType where dataType == "basketball_player_info":
            let responseModel = try container.decode(NBAPlayerInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaPlayerInfoConverter(response: responseModel)
                self.data = .nbaPlayerInfo(responseModel, displayModel)
            }
            
        case let dataType where dataType == "basketball_player_stats":
            let responseModel = try container.decode(NBAPlayerInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaPlayerStatsConverter(response: responseModel)
                self.data = .nbaPlayerStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "basketball_player_standings":
            let responseModel = try container.decode(NBAPlayerStandingsResponseModel.self, forKey: .data)
            
            if responseModel.standings.isEmpty {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaPlayerStandingsConverter(response: responseModel)
                self.data = .nbaPlayerStandings(responseModel, displayModel)
            }
            
        case let dataType where dataType == "basketball_team_info":
            let responseModel = try container.decode(NBATeamInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaTeamInfoConverter(response: responseModel)
                self.data = .nbaTeamInfo(responseModel, displayModel)
            }
            
        case let dataType where dataType == "basketball_team_stats":
            let responseModel = try container.decode(NBATeamInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaTeamStatsConverter(response: responseModel)
                self.data = .nbaTeamStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "basketball_team_standings":
            let responseModel = try container.decode(NBATeamStandingsResponseModel.self, forKey: .data)
            
            if responseModel.standings.isEmpty {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaTeamStandingsConverter(response: responseModel)
                self.data = .nbaTeamStandings(responseModel, displayModel)
            }
            
        case let dataType where dataType == "basketball_team_schedule":
            let responseModel = try container.decode(NBAGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.nbaTeamScheduleConverter(response: responseModel)
            self.data = .nbaTeamSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "basketball_league_schedule":
            let responseModel = try container.decode(NBAGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.nbaLeagueScheduleConverter(response: responseModel)
            self.data = .nbaLeagueSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "basketball_game_stats":
            let responseModel = try container.decode(NBAGameStatsReponseModel.self, forKey: .data)
            
            if responseModel.game == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaGameStatsConverter(response: responseModel)
                self.data = .nbaGameStats(responseModel, displayModel)
            }
            
        default:
            data = .unknown
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case dataType, keywords, entityInfo, data
    }
}


