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
    let season: Int
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

// Used for json mock data test
enum SportDisplayType: Hashable, CaseIterable {
    // football
    case fbPlayerInfo, fbPlayerStats, fbPlayerStandings, fbTeamInfo, fbTeamStats, fbTeamStandings, fbLeagueSchedule, fbGameStats, fbTournament
    // nba
    case nbaPlayerInfo, nbaPlayerStats, nbaPlayerStandings, nbaTeamInfo, nbaTeamStats, nbaTeamStandings, nbaLeagueSchedule, nbaGameStats, nbaTournament
    // kbo
    case kboPlayerInfo, kboPlayerStats, kboPlayerStandings, kboTeamInfo, kboTeamStats, kboTeamStandings, kboLeagueSchedule, kboGameStats, kboTournament
    // mlb
    case mlbPlayerInfo, mlbPlayerStats, mlbPlayerStandings, mlbTeamInfo, mlbTeamStats, mlbTeamStandings, mlbLeagueSchedule, mlbGameStats, mlbTournament
    // tennis
    case tennisPlayerStandings, tennisLeagueSchedule, tennisGameStats, tennisTournament
    
    case unknown
    
    // VStack안에서 view를 그릴때 순서가 필요한 경우에 사용
    var sortOrder: Int {
        switch self {
        case .fbLeagueSchedule: return 0
        default: return 1
        }
    }
}

indirect enum SportDecodableModel: Equatable {
    // football
    case fbPlayerInfo(FBPlayerInfoResponseModel, FBPlayerInfoDisplayModel)
    case fbPlayerStats(FBPlayerInfoResponseModel, FBPlayerStatsDisplayModel)
    case fbPlayerStandings(FBPlayerStandingsResponseModel, FBPlayerStandingsDisplayModel)
    case fbTeamInfo(FBTeamInfoResponseModel, FBTeamInfoDisplayModel)
    case fbTeamStats(FBTeamInfoResponseModel, FBTeamStatsDisplayModel)
    case fbTeamStandings(FBTeamStandingsResponseModel, FBTeamStandingsDisplayModel)
    case fbLeagueSchedule(FBGameScheduleResponseModel, FBLeagueScheduleDisplayModel)
    case fbGameStats(FBGameStatsResponseModel, FBGameStatsDisplayModel)
    case fbTournament(FBGameScheduleResponseModel, FBTournamentDisplayModel)
    
    // nba
    case nbaPlayerInfo(NBAPlayerInfoResponseModel, NBAPlayerInfoDisplayModel)
    case nbaPlayerStats(NBAPlayerInfoResponseModel, NBAPlayerStatsDisplayModel)
    case nbaPlayerStandings(NBAPlayerStandingsResponseModel, NBAPlayerStandingsDisplayModel)
    case nbaTeamInfo(NBATeamInfoResponseModel, NBATeamInfoDisplayModel)
    case nbaTeamStats(NBATeamInfoResponseModel, NBATeamStatsDisplayModel)
    case nbaTeamStandings(NBATeamStandingsResponseModel, NBATeamStandingsDisplayModel)
    case nbaLeagueSchedule(NBAGameScheduleResponseModel, NBALeagueScheduleDisplayModel)
    case nbaGameStats(NBAGameStatsResponseModel, NBAGameStatsDisplayModel)
    case nbaTournament(NBAGameScheduleResponseModel, NBATournamentDisplayModel)
    
    // kbo
    case kboPlayerInfo(KBOPlayerInfoResponseModel, KBOPlayerInfoDisplayModel)
    case kboPlayerStats(KBOPlayerInfoResponseModel, KBOPlayerStatsDisplayModel)
    case kboPlayerStandings(KBOPlayerStandingsResponseModel, KBOPlayerStandingsDisplayModel)
    case kboTeamInfo(KBOTeamInfoResponseModel, KBOTeamInfoDisplayModel)
    case kboTeamStats(KBOTeamInfoResponseModel, KBOTeamStatsDisplayModel)
    case kboTeamStandings(KBOTeamStandingsResponseModel, KBOTeamStandingsDisplayModel)
    case kboLeagueSchedule(KBOGameScheduleResponseModel, KBOLeagueScheduleDisplayModel)
    case kboGameStats(KBOGameStatsResponseModel, KBOGameStatsDisplayModel)
    case kboTournament(KBOGameScheduleResponseModel, KBOTournamentDisplayModel)
    
    // mlb
    case mlbPlayerInfo(MLBPlayerInfoResponseModel, MLBPlayerInfoDisplayModel)
    case mlbPlayerStats(MLBPlayerInfoResponseModel, MLBPlayerStatsDisplayModel)
    case mlbPlayerStandings(MLBPlayerStandingsResponseModel, MLBPlayerStandingsDisplayModel)
    case mlbTeamInfo(MLBTeamInfoResponseModel, MLBTeamInfoDisplayModel)
    case mlbTeamStats(MLBTeamInfoResponseModel, MLBTeamStatsDisplayModel)
    case mlbTeamStandings(MLBTeamStandingsResponseModel, MLBTeamStandingsDisplayModel)
    case mlbLeagueSchedule(MLBGameScheduleResponseModel, MLBLeagueScheduleDisplayModel)
    case mlbGameStats(MLBGameStatsResponseModel, MLBGameStatsDisplayModel)
    case mlbTournament(MLBGameScheduleResponseModel, MLBTournamentDisplayModel)
    
    // tennis
    case tennisPlayerStandings(TennisPlayerStandingsResponseModel, TennisPlayerStandingsDisplayModel)
    case tennisLeagueSchedule(TennisGameScheduleResponseModel, TennisLeagueScheduleDisplayModel)
    case tennisGameStats(TennisGameStatsResponseModel, TennisGameStatsDisplayModel)
    case tennisTournament(TennisGameScheduleResponseModel, TennisTournamentDisplayModel)
    
    case unknown
    
    static func == (lhs: SportDecodableModel, rhs: SportDecodableModel) -> Bool {
        switch (lhs, rhs) {
        case (.fbPlayerInfo, .fbPlayerInfo),
            (.fbPlayerStats, .fbPlayerStats),
            (.fbPlayerStandings, .fbPlayerStandings),
            (.fbTeamInfo, .fbTeamInfo),
            (.fbTeamStats, .fbTeamStats),
            (.fbTeamStandings, .fbTeamStandings),
            (.fbLeagueSchedule, .fbLeagueSchedule),
            (.fbTournament, .fbTournament),
            (.fbGameStats, .fbGameStats),
            (.nbaPlayerInfo, .nbaPlayerInfo),
            (.nbaPlayerStats, .nbaPlayerStats),
            (.nbaPlayerStandings, .nbaPlayerStandings),
            (.nbaTeamInfo, .nbaTeamInfo),
            (.nbaTeamStats, .nbaTeamStats),
            (.nbaTeamStandings, .nbaTeamStandings),
            (.nbaLeagueSchedule, .nbaLeagueSchedule),
            (.nbaGameStats, .nbaGameStats),
            (.nbaTournament, .nbaTournament),
            (.kboPlayerInfo, .kboPlayerInfo),
            (.kboPlayerStats, .kboPlayerStats),
            (.kboPlayerStandings, .kboPlayerStandings),
            (.kboTeamInfo, .kboTeamInfo),
            (.kboTeamStats, .kboTeamStats),
            (.kboTeamStandings, .kboTeamStandings),
            (.kboLeagueSchedule, .kboLeagueSchedule),
            (.kboGameStats, .kboGameStats),
            (.kboTournament, .kboTournament),
            (.mlbPlayerInfo, .mlbPlayerInfo),
            (.mlbPlayerStats, .mlbPlayerStats),
            (.mlbPlayerStandings, .mlbPlayerStandings),
            (.mlbTeamInfo, .mlbTeamInfo),
            (.mlbTeamStats, .mlbTeamStats),
            (.mlbTeamStandings, .mlbTeamStandings),
            (.mlbLeagueSchedule, .mlbLeagueSchedule),
            (.mlbGameStats, .mlbGameStats),
            (.mlbTournament, .mlbTournament),
            (.tennisPlayerStandings, .tennisPlayerStandings),
            (.tennisLeagueSchedule, .tennisLeagueSchedule),
            (.tennisGameStats, .tennisGameStats),
            (.tennisTournament, .tennisTournament),
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
        self.keywords = try container.decodeIfPresent([Keyword].self, forKey: .keywords) ?? []
        
        self.entityInfo = try container.decode([EntityInfo].self, forKey: .entityInfo)
        self.season = try container.decode(Int.self, forKey: .season)
        
        let leagueId = self.entityInfo.first?.leagueId
        
        let modelConverter = ModelConverter.shared
        modelConverter.configure(
            keywords: keywords,
            entityInfo: entityInfo,
            season: season
        )
        
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
            
        case let dataType where dataType == "football_league_schedule":
            let responseModel = try container.decode(FBGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.fbLeagueScheduleConverter(response: responseModel)
            self.data = .fbLeagueSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "football_game_stats":
            let responseModel = try container.decode(FBGameStatsResponseModel.self, forKey: .data)
            
            if responseModel.game == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.fbGameStatsConverter(response: responseModel)
                self.data = .fbGameStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "football_league_tournament":
            let responseModel = try container.decode(FBGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.fbTournamentConverter(response: responseModel)
            self.data = .fbTournament(responseModel, displayModel)
            
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
            
        case let dataType where dataType == "basketball_league_schedule":
            let responseModel = try container.decode(NBAGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.nbaLeagueScheduleConverter(response: responseModel)
            self.data = .nbaLeagueSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "basketball_game_stats":
            let responseModel = try container.decode(NBAGameStatsResponseModel.self, forKey: .data)
            
            if responseModel.game == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.nbaGameStatsConverter(response: responseModel)
                self.data = .nbaGameStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "basketball_league_tournament":
            let responseModel = try container.decode(NBAGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.nbaTournamentConverter(response: responseModel)
            self.data = .nbaTournament(responseModel, displayModel)
            
        // baseball
        case let dataType where dataType == "baseball_player_info":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOPlayerInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.kboPlayerInfoConverter(response: responseModel)
                    self.data = .kboPlayerInfo(responseModel, displayModel)
                }
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBPlayerInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.mlbPlayerInfoConverter(response: responseModel)
                    self.data = .mlbPlayerInfo(responseModel, displayModel)
                }
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_player_stats":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOPlayerInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.kboPlayerStatsConverter(response: responseModel)
                    self.data = .kboPlayerStats(responseModel, displayModel)
                }
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBPlayerInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.mlbPlayerStatsConverter(response: responseModel)
                    self.data = .mlbPlayerStats(responseModel, displayModel)
                }
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_player_standings":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOPlayerStandingsResponseModel.self, forKey: .data)
                
//                if responseModel.info == nil {
//                    self.data = .unknown
//                } else {
                    let displayModel = modelConverter.kboPlayerStandingsConverter(response: responseModel)
                    self.data = .kboPlayerStandings(responseModel, displayModel)
//                }
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBPlayerStandingsResponseModel.self, forKey: .data)
                
//                if responseModel.info == nil {
//                    self.data = .unknown
//                } else {
                    let displayModel = modelConverter.mlbPlayerStandingsConverter(response: responseModel)
                    self.data = .mlbPlayerStandings(responseModel, displayModel)
//                }
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_team_info":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOTeamInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.kboTeamInfoConverter(response: responseModel)
                    self.data = .kboTeamInfo(responseModel, displayModel)
                }
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBTeamInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.mlbTeamInfoConverter(response: responseModel)
                    self.data = .mlbTeamInfo(responseModel, displayModel)
                }
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_team_stats":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOTeamInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.kboTeamStatsConverter(response: responseModel)
                    self.data = .kboTeamStats(responseModel, displayModel)
                }
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBTeamInfoResponseModel.self, forKey: .data)
                
                if responseModel.info == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.mlbTeamStatsConverter(response: responseModel)
                    self.data = .mlbTeamStats(responseModel, displayModel)
                }
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_team_standings":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOTeamStandingsResponseModel.self, forKey: .data)
                
                if responseModel.standings.isEmpty {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.kboTeamStandingsConverter(response: responseModel)
                    self.data = .kboTeamStandings(responseModel, displayModel)
                }
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBTeamStandingsResponseModel.self, forKey: .data)
                
                if responseModel.standings.isEmpty {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.mlbTeamStandingsConverter(response: responseModel)
                    self.data = .mlbTeamStandings(responseModel, displayModel)
                }
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_league_schedule":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOGameScheduleResponseModel.self, forKey: .data)
                let displayModel = modelConverter.kboLeagueScheduleConverter(response: responseModel)
                self.data = .kboLeagueSchedule(responseModel, displayModel)
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBGameScheduleResponseModel.self, forKey: .data)
                let displayModel = modelConverter.mlbLeagueScheduleConverter(response: responseModel)
                self.data = .mlbLeagueSchedule(responseModel, displayModel)
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_game_stats":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOGameStatsResponseModel.self, forKey: .data)
                
                if responseModel.game == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.kboGameStatsConverter(response: responseModel)
                    self.data = .kboGameStats(responseModel, displayModel)
                }
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBGameStatsResponseModel.self, forKey: .data)
                
                if responseModel.game == nil {
                    self.data = .unknown
                } else {
                    let displayModel = modelConverter.mlbGameStatsConverter(response: responseModel)
                    self.data = .mlbGameStats(responseModel, displayModel)
                }
            } else {
                self.data = .unknown
            }
            
        case let dataType where dataType == "baseball_league_tournament":
            if leagueId == Constants.Ids.kbo {
                let responseModel = try container.decode(KBOGameScheduleResponseModel.self, forKey: .data)
                let displayModel = modelConverter.kboTournamentConverter(response: responseModel)
                self.data = .kboTournament(responseModel, displayModel)
            } else if leagueId == Constants.Ids.mlb {
                let responseModel = try container.decode(MLBGameScheduleResponseModel.self, forKey: .data)
                let displayModel = modelConverter.mlbTournamentConverter(response: responseModel)
                self.data = .mlbTournament(responseModel, displayModel)
            } else {
                self.data = .unknown
            }
            
        // tennis
        case let dataType where dataType == "tennis_player_standings":
            let responseModel = try container.decode(TennisPlayerStandingsResponseModel.self, forKey: .data)
            
//            if responseModel.standings.isEmpty {
                self.data = .unknown
//            } else {
//                let displayModel = modelConverter.fbPlayerStandingsConverter(response: responseModel)
//                self.data = .fbPlayerStandings(responseModel, displayModel)
//            }
            
        case let dataType where dataType == "tennis_league_schedule":
            let responseModel = try container.decode(TennisGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.tennisLeagueScheduleConverter(response: responseModel)
            self.data = .tennisLeagueSchedule(responseModel, displayModel)
            
        case let dataType where dataType == "tennis_game_stats":
            let responseModel = try container.decode(TennisGameStatsResponseModel.self, forKey: .data)
            
            if responseModel.game == nil {
                self.data = .unknown
            } else {
                let displayModel = modelConverter.tennisGameStatsConverter(response: responseModel)
                self.data = .tennisGameStats(responseModel, displayModel)
            }
            
        case let dataType where dataType == "tennis_league_tournament":
            let responseModel = try container.decode(TennisGameScheduleResponseModel.self, forKey: .data)
            let displayModel = modelConverter.tennisTournamentConverter(response: responseModel)
            self.data = .tennisTournament(responseModel, displayModel)
            
        default:
            self.data = .unknown
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case dataType, keywords, entityInfo, data, season
    }
}


