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
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
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
        
        return FBPlayerStatsDisplayModel(
            player: info.player,
            team: stats?.team,
            stats: info.statistics,
            leagueId: leagueId
        )
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
        
        return FBPlayerStandingsDisplayModel(
            keywords: keywords,
            entityInfo: entityInfo,
            standings: standings,
            leagueId: leagueId
        )
    }
    
    func fbTeamInfoConverter(response: FBTeamInfoResponseModel) -> FBTeamInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.league.id == leagueId }
        
        return FBTeamInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            team: info.team,
            venue: info.venue,
            stats: stats,
            lastGame: response.lastGame,
            nextGame: response.nextGame
        )
    }
    
    func fbTeamStatsConverter(response: FBTeamInfoResponseModel) -> FBTeamStatsDisplayModel {
        let info = response.info!
        
        return FBTeamStatsDisplayModel(
            team: info.team,
            venue: info.venue,
            stats: info.statistics,
            leagueId: leagueId
        )
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
        
        return FBTeamStandingsDisplayModel(
            keywords: keywords,
            league: league,
            standings: standings,
            leagueId: leagueId
        )
    }
    
    func fbTeamScheduleConverter(response: FBGameScheduleResponseModel) -> FBTeamScheduleDisplayModel {
        return FBTeamScheduleDisplayModel(
            games: response.schedule,
            leagueId: leagueId
        )
    }
    
    func fbLeagueScheduleConverter(response: FBGameScheduleResponseModel) -> FBLeagueScheduleDisplayModel {
        let yearMonthList: [String] = response.scheduledMonths?.map {
            let components = $0.split(separator: "-")
            guard components.count == 2 else { return "" }
            
            return "\(components[0].suffix(2))/\(components[1])"
        } ?? []
        
        return FBLeagueScheduleDisplayModel(
            yearMonthList: yearMonthList,
            games: response.schedule,
            entityInfo: entityInfo,
            leagueId: leagueId
        )
    }
    
    func fbGameStatsConverter(response: FBGameStatsReponseModel) -> FBGameStatsDisplayModel {
        return FBGameStatsDisplayModel(
            game: response.game!,
            leagueId: leagueId
        )
    }
    
    /* ---------------------
       nba
       --------------------- */
    func nbaPlayerInfoConverter(response: NBAPlayerInfoResponseModel) -> NBAPlayerInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.seasonType == "Regular Season" }
        
        let lastGameTeam = if response.lastGame?.boxScoreTraditional?.homeTeamId == entityInfo.first?.teamId {
            response.lastGame?.boxScoreTraditional?.homeTeam
        } else {
            response.lastGame?.boxScoreTraditional?.awayTeam
        }
        
        let lastGamePlayerStats = lastGameTeam?.players.first {
            $0.personId == entityInfo.first?.playerId
        }
        
        return NBAPlayerInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            info: info.player,
            stats: stats,
            lastGame: response.lastGame,
            lastGamePlayerStats: lastGamePlayerStats,
            nextGame: response.nextGame
        )
    }
    
    func nbaPlayerStatsConverter(response: NBAPlayerInfoResponseModel) -> NBAPlayerStatsDisplayModel {
        let info = response.info!
        
        return NBAPlayerStatsDisplayModel(player: info.player, stats: info.statistics)
    }
    
    func nbaPlayerStandingsConverter(response: NBAPlayerStandingsResponseModel) -> NBAPlayerStandingsDisplayModel {
        let standings: [NBAPlayerStandingsDisplay] = response.standings.compactMap { playerInfo in
            let player = playerInfo.player
            let statsList = playerInfo.statistics
            
            for item in statsList {
                if item.seasonType == "Regular Season" {
                    return NBAPlayerStandingsDisplay(player: player, stats: item)
                }
            }
            
            return nil
        }
        
        return NBAPlayerStandingsDisplayModel(keywords: keywords, entityInfo: entityInfo, standings: standings)
    }
    
    func nbaTeamInfoConverter(response: NBATeamInfoResponseModel) -> NBATeamInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.seasonType == "Regular Season" }
        
        return NBATeamInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            team: info.team,
            venue: info.venue,
            stats: stats,
            lastGame: response.lastGame,
            nextGame: response.nextGame
        )
    }
    
    func nbaTeamStatsConverter(response: NBATeamInfoResponseModel) -> NBATeamStatsDisplayModel {
        let info = response.info!
        
        return NBATeamStatsDisplayModel(team: info.team, venue: info.venue, stats: info.statistics)
    }
    
    func nbaTeamStandingsConverter(response: NBATeamStandingsResponseModel) -> NBATeamStandingsDisplayModel {
        let standings: [NBATeamStandingsDisplay] = response.standings.compactMap { teamInfo in
            let statsList = teamInfo.statistics
            
            for item in statsList {
                if item.seasonType == "Regular Season" {
                    return NBATeamStandingsDisplay(
                        team: teamInfo.team,
                        stats: item
                    )
                }
            }
            
            return nil
        }
        
        return NBATeamStandingsDisplayModel(keywords: keywords, entityInfo: entityInfo, standings: standings)
    }
    
    func nbaTeamScheduleConverter(response: NBAGameScheduleResponseModel) -> NBATeamScheduleDisplayModel {
        return NBATeamScheduleDisplayModel(games: response.schedule)
    }
    
    func nbaLeagueScheduleConverter(response: NBAGameScheduleResponseModel) -> NBALeagueScheduleDisplayModel {
        let yearMonthList: [String] = response.scheduledMonths?.map {
            let components = $0.split(separator: "-")
            guard components.count == 2 else { return "" }
            
            return "\(components[0].suffix(2))/\(components[1])"
        } ?? []
        
        return NBALeagueScheduleDisplayModel(yearMonthList: yearMonthList, games: response.schedule, entityInfo: entityInfo)
    }
    
    func nbaGameStatsConverter(response: NBAGameStatsReponseModel) -> NBAGameStatsDisplayModel {
        return NBAGameStatsDisplayModel(game: response.game!)
    }
    
    func nbaLeagueTournamentConverter(response: NBAGameListResponseModel) -> NBATournamentDisplayModel {
        return NBATournamentDisplayModel(yearMonthList: [], games: response.schedule, entityInfo: entityInfo)
    }
    
    // Not used in DataModel
    func nbaGameToGameScheduleConverter(gameList: [NBAGame]) -> [NBAGameForSchedule] {
        return gameList.compactMap { game in
            guard let gameSummary = game.gameSummary else {
                return nil
            }
            
            let homeTeamId = gameSummary.homeTeamId
            let awayTeamId = gameSummary.visitorTeamId
            let homeTeamScore = game.lineScore.first { $0.teamId == homeTeamId }?.pts ?? 0
            let awayTeamScore = game.lineScore.first { $0.teamId == awayTeamId }?.pts ?? 0
            
            return NBAGameForSchedule(
                itemKey: "\(gameSummary.date)#\(gameSummary.gameCode)",
                homeTeamId: homeTeamId,
                awayTeamId: awayTeamId,
                homeTeamScore: homeTeamScore,
                awayTeamScore: awayTeamScore,
                gameStatus: String(gameSummary.gameStatusId),
                gameInfo: gameSummary
            )
        }
    }
}
