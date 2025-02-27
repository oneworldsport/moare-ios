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

struct EntityInfo: Codable {
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
                data = .fbPlayerStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_player_standings":
            let responseModel = try container.decode(FBPlayerStandingsResponseModel.self, forKey: .data)
            
            if responseModel.standings.isEmpty {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbPlayerStandingsConverter(response: responseModel)
                data = .fbPlayerStandings(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_info":
            let responseModel = try container.decode(FBTeamInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbTeamInfoConverter(response: responseModel)
                data = .fbTeamInfo(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_stats":
            let responseModel = try container.decode(FBTeamInfoResponseModel.self, forKey: .data)
            
            if responseModel.info == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbTeamStatsConverter(response: responseModel)
                data = .fbTeamStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_standings":
            let responseModel = try container.decode(FBTeamStandingsResponseModel.self, forKey: .data)
            
            if responseModel.standings.isEmpty {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbTeamStandingsConverter(response: responseModel)
                data = .fbTeamStandings(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_team_schedule":
            let responseModel = try container.decode(FBGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.fbTeamScheduleConverter(response: responseModel)
            data = .fbTeamSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "football_league_schedule":
            let responseModel = try container.decode(FBGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.fbLeagueScheduleConverter(response: responseModel)
            data = .fbLeagueSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "football_game_stats":
            let responseModel = try container.decode(FBGameStatsReponseModel.self, forKey: .data)
            
            if responseModel.game == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbGameStatsConverter(response: responseModel)
                data = .fbGameStats(responseModel, displayModel)
            }
            
        default:
            data = .unknown
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case dataType, keywords, entityInfo, data
    }
}


