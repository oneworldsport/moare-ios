//
//  ModelConverter.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/7/24.
//

import Foundation

struct ModelConverter {
    let keywords: [Keyword]
    let entityInfo: [EntityInfo]
    let leagueId: Int?
    
    init(keywords: [Keyword] = [], entityInfo: [EntityInfo] = []) {
        self.keywords = keywords
        self.entityInfo = entityInfo
        self.leagueId = entityInfo.first?.leagueId
    }
    
    /* ---------------------
       football
       --------------------- */
    func fbPlayerInfoConverter(response: FBPlayerInfoResponseModel) -> FBPlayerInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.league.id == leagueId }
        
        let lastGameTeamPlayers = response.lastGame?.players.first { $0.team.id == entityInfo.first?.teamId }
        let lastGamePlayerStats = lastGameTeamPlayers?.players.first {
            $0.player.id == entityInfo.first?.playerId
        }?.statistics.first
        
        return FBPlayerInfoDisplayModel(
            info: info.player,
            stats: stats,
            lastGame: response.lastGame,
            lastGamePlayerStats: lastGamePlayerStats,
            nextGame: response.nextGame
        )
    }
    
    func fbPlayerStatsConverter(response: FBPlayerInfoResponseModel) -> FBPlayerStatsDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.league.id == leagueId }
        
        return FBPlayerStatsDisplayModel(player: info.player, team: stats?.team, stats: info.statistics)
    }
    
    func fbPlayerStandingsConverter(response: FBPlayerStandingsResponseModel) -> FBPlayerStandingsDisplayModel {
        let standings: [FBPlayerStandingsDisplay] = response.standings.compactMap { playerInfo in
            let player = playerInfo.player
            let statsList = playerInfo.statistics
            
            for item in statsList {
                if item.league.id == leagueId {
                    return FBPlayerStandingsDisplay(player: player, stats: item)
                }
            }
            
            return nil
        }
        
        return FBPlayerStandingsDisplayModel(keywords: keywords, standings: standings)
    }
    
    func fbTeamInfoConverter(response: FBTeamInfoResponseModel) -> FBTeamInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.league.id == leagueId }
        
        return FBTeamInfoDisplayModel(team: info.team, venue: info.venue, stats: stats, lastGame: response.lastGame, nextGame: response.nextGame)
    }
    
    func fbTeamStatsConverter(response: FBTeamInfoResponseModel) -> FBTeamStatsDisplayModel {
        let info = response.info!
        
        return FBTeamStatsDisplayModel(team: info.team, venue: info.venue, stats: info.statistics)
    }
    
    func fbTeamStandingsConverter(response: FBTeamStandingsResponseModel) -> FBTeamStandingsDisplayModel {
        var league: FBLeague? = nil
        
        let standings: [FBTeamStandingsDisplay] = response.standings.compactMap { teamInfo in
            let stats = teamInfo.statistics
            
            for item in stats {
                if item.league.id == leagueId {
                    if league == nil {
                        league = item.league
                    }
                    
                    return FBTeamStandingsDisplay(
                        team: item.team,
                        homeAwayStats: item.fixtures,
                        goalsFor: item.goals.teamGoalsFor.total,
                        goalsAgainst: item.goals.teamGoalsAgainst.total
                    )
                }
            }
            
            return nil
        }
        
        return FBTeamStandingsDisplayModel(keywords: keywords, league: league, standings: standings)
    }
    
    func fbTeamScheduleConverter(response: FBGameScheduleResponseModel) -> FBTeamScheduleDisplayModel {
        return FBTeamScheduleDisplayModel(games: response.schedule)
    }
    
    func fbLeagueScheduleConverter(response: FBGameScheduleResponseModel) -> FBLeagueScheduleDisplayModel {
//        let calendar = Calendar.current
//        
//        var yearMonthList = response.schedule.compactMap { game -> String? in
//            if let date = ISO8601DateFormatter().date(from: game.fixture.date) {
//                let year = calendar.component(.year, from: date) % 100
//                let month = calendar.component(.month, from: date)
//                return String(format: "%02d/%02d", year, month)
//            }
//            
//            return nil
//        }
//        
//        yearMonthList = Array(Set(yearMonthList))
//        
//        yearMonthList.sort()

        let yearMonthList = response.scheduledMonths.map {
            let components = $0.split(separator: "-")
            guard components.count == 2 else { return "" }
            
            return "\(components[0].suffix(2))/\(components[1])"
        }
        
        return FBLeagueScheduleDisplayModel(yearMonthList: yearMonthList, games: response.schedule)
    }
    
    func fbGameStatsConverter(response: FBGameStatsReponseModel) -> FBGameStatsDisplayModel {
        return FBGameStatsDisplayModel(game: response.game!)
    }
}
