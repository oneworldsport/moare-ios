//
//  ModelConverter.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/7/24.
//

import Foundation

final class ModelConverter {
    static let shared = ModelConverter()
    private init() {}
    
    private(set) var keywords: [Keyword] = []
    private(set) var entityInfo: [EntityInfo] = []
    private(set) var leagueId: Int? = nil
    private(set) var season: Int = CalendarUtil.currentYear
    
    func configure(
        keywords: [Keyword],
        entityInfo: [EntityInfo],
        season: Int
    ) {
        self.keywords = keywords
        self.entityInfo = entityInfo
        self.leagueId = entityInfo.first?.leagueId
        self.season = season
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
            season: season,
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
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            player: info.player,
            team: stats?.team,
            stats: info.statistics
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
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            standings: standings
        )
    }
    
    func fbTeamInfoConverter(response: FBTeamInfoResponseModel) -> FBTeamInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.league.id == leagueId }
        
        return FBTeamInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
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
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            team: info.team,
            venue: info.venue,
            stats: info.statistics
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
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            league: league,
            standings: standings
        )
    }
    
    func fbLeagueScheduleConverter(response: FBGameScheduleResponseModel) -> FBLeagueScheduleDisplayModel {
        let yearMonthList: [String] = response.scheduledMonths?.map {
            let components = $0.split(separator: "-")
            guard components.count == 2 else { return "" }
            
            return "\(components[0].suffix(2))/\(components[1])"
        } ?? []
        
        return FBLeagueScheduleDisplayModel(
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .league,
            yearMonthList: yearMonthList,
            games: response.schedule
        )
    }
    
    func fbGameStatsConverter(response: FBGameStatsResponseModel) -> FBGameStatsDisplayModel {
        let game = response.game!
        return FBGameStatsDisplayModel(
            leagueId: game.league.id,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            game: game
        )
    }
    
    func fbTournamentConverter(response: FBGameScheduleResponseModel) -> FBTournamentDisplayModel {
        return FBTournamentDisplayModel(
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .tournamentDraw,
            games: response.schedule
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
            season: season,
            info: info.player,
            stats: stats,
            lastGame: response.lastGame,
            lastGamePlayerStats: lastGamePlayerStats,
            nextGame: response.nextGame
        )
    }
    
    func nbaPlayerStatsConverter(response: NBAPlayerInfoResponseModel) -> NBAPlayerStatsDisplayModel {
        let info = response.info!
        
        return NBAPlayerStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            player: info.player,
            stats: info.statistics
        )
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
        
        return NBAPlayerStandingsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            standings: standings
        )
    }
    
    func nbaTeamInfoConverter(response: NBATeamInfoResponseModel) -> NBATeamInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.seasonType == "Regular Season" }
        
        return NBATeamInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            team: info.team,
            venue: info.venue,
            stats: stats,
            lastGame: response.lastGame,
            nextGame: response.nextGame
        )
    }
    
    func nbaTeamStatsConverter(response: NBATeamInfoResponseModel) -> NBATeamStatsDisplayModel {
        let info = response.info!
        
        return NBATeamStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            team: info.team,
            venue: info.venue,
            stats: info.statistics
        )
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
        
        return NBATeamStandingsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            standings: standings
        )
    }
    
    func nbaLeagueScheduleConverter(response: NBAGameScheduleResponseModel) -> NBALeagueScheduleDisplayModel {
        let yearMonthList: [String] = response.scheduledMonths?.map {
            let components = $0.split(separator: "-")
            guard components.count == 2 else { return "" }
            
            return "\(components[0].suffix(2))/\(components[1])"
        } ?? []
        
        return NBALeagueScheduleDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .league,
            yearMonthList: yearMonthList,
            games: response.schedule
        )
    }
    
    func nbaGameStatsConverter(response: NBAGameStatsResponseModel) -> NBAGameStatsDisplayModel {
        return NBAGameStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            game: response.game!
        )
    }
    
    func nbaTournamentConverter(response: NBAGameScheduleResponseModel) -> NBATournamentDisplayModel {
        return NBATournamentDisplayModel(
            leagueId: leagueId ?? Constants.Ids.nba,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .tournamentBracket,
            games: response.schedule
        )
    }
    
    /* ---------------------
       kbo
       --------------------- */
    func kboPlayerInfoConverter(response: KBOPlayerInfoResponseModel) -> KBOPlayerInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.seasonType == "Regular Season" }
        
        let lastGame = response.lastGame
        let isHome = Int(lastGame?.gameInfo?.homeTeamId ?? 0) == info.player.teamId
        
        var lastGamePlayerHitterStats: KBOGameHitterStats?
        var lastGamePlayerPitcherStats: KBOGamePitcherStats? = nil
        
        if isHome {
            lastGamePlayerHitterStats = lastGame?.lineup?.home.hitters.first { $0.id == info.player.id }
            if lastGamePlayerHitterStats == nil {
                lastGamePlayerPitcherStats = lastGame?.lineup?.home.pitchers.first { $0.id == info.player.id }
            }
        } else {
            lastGamePlayerHitterStats = lastGame?.lineup?.away.hitters.first { $0.id == info.player.id }
            if lastGamePlayerHitterStats == nil {
                lastGamePlayerPitcherStats = lastGame?.lineup?.away.pitchers.first { $0.id == info.player.id }
            }
        }
        
        return KBOPlayerInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.epl,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            info: info.player,
            stats: stats,
            lastGame: response.lastGame,
            lastGamePlayerHitterStats: lastGamePlayerHitterStats,
            lastGamePlayerPitcherStats: lastGamePlayerPitcherStats,
            nextGame: response.nextGame
        )
    }
    
    func kboPlayerStatsConverter(response: KBOPlayerInfoResponseModel) -> KBOPlayerStatsDisplayModel {
        let info = response.info!
        
        return KBOPlayerStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            player: info.player,
            stats: info.statistics
        )
    }
    
    func kboPlayerStandingsConverter(response: KBOPlayerStandingsResponseModel) -> KBOPlayerStandingsDisplayModel {
        let standings: [KBOPlayerStandingsDisplay] = response.standings.compactMap { playerInfo in
            let player = playerInfo.player
            let statsList = playerInfo.statistics
            
            for item in statsList {
                if item.seasonType == "Regular Season" {
                    return KBOPlayerStandingsDisplay(player: player, stats: item)
                }
            }
            
            return nil
        }
        
        return KBOPlayerStandingsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            standings: standings
        )
    }
    
    func kboTeamInfoConverter(response: KBOTeamInfoResponseModel) -> KBOTeamInfoDisplayModel {
        let info = response.info!
        
        // TODO: statistics에 season정보 추가
//        let stats = info.statistics.first { $0.league.id == leagueId }
        
        return KBOTeamInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            team: info.team,
            venue: info.venue,
            stats: info.statistics.first,
            lastGame: response.lastGame,
            nextGame: response.nextGame
        )
    }
    
    func kboTeamStatsConverter(response: KBOTeamInfoResponseModel) -> KBOTeamStatsDisplayModel {
        let info = response.info!
        
        return KBOTeamStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            team: info.team,
            venue: info.venue,
            stats: info.statistics
        )
    }
    
    func kboTeamStandingsConverter(response: KBOTeamStandingsResponseModel) -> KBOTeamStandingsDisplayModel {
        let standings: [KBOTeamStandingsDisplay] = response.standings.compactMap { teamInfo in
            let stats = teamInfo.statistics.first
            
            return KBOTeamStandingsDisplay(team: teamInfo.team, stats: stats!)
        }
        
        return KBOTeamStandingsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            standings: standings
        )
    }
    
    func kboLeagueScheduleConverter(response: KBOGameScheduleResponseModel) -> KBOLeagueScheduleDisplayModel {
        let yearMonthList: [String] = response.scheduledMonths?.map {
            let components = $0.split(separator: "-")
            guard components.count == 2 else { return "" }
            
            return "\(components[0].suffix(2))/\(components[1])"
        } ?? []
        
        return KBOLeagueScheduleDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .league,
            yearMonthList: yearMonthList,
            games: response.schedule
        )
    }
    
    func kboGameStatsConverter(response: KBOGameStatsResponseModel) -> KBOGameStatsDisplayModel {
        return KBOGameStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            game: response.game!
        )
    }
    
    func kboTournamentConverter(response: KBOGameScheduleResponseModel) -> KBOTournamentDisplayModel {
        return KBOTournamentDisplayModel(
            leagueId: leagueId ?? Constants.Ids.kbo,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .tournamentBracket,
            games: response.schedule
        )
    }
    
    /* ---------------------
       mlb
       --------------------- */
    func mlbPlayerInfoConverter(response: MLBPlayerInfoResponseModel) -> MLBPlayerInfoDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.type == "season" }
        let teamId: Int? = {
            if let id = stats?.hitting?.team?.id {
                return id
            } else if let id = stats?.fielding?.team.id {
                return id
            } else if let id = stats?.catching?.team.id {
                return id
            } else if let id = stats?.pitching?.team.id {
                return id
            } else {
                return nil
            }
        }()
  
        var lastGamePlayerStats: MLBGameBoxscoreTeamPlayer? = nil
        if response.lastGame?.teams.home.id == teamId {
            lastGamePlayerStats = response.lastGame?.boxscore?.teams.home.players["ID\(info.player.id)"]
        } else if response.lastGame?.teams.away.id == teamId {
            lastGamePlayerStats = response.lastGame?.boxscore?.teams.away.players["ID\(info.player.id)"]
        }
        
        return MLBPlayerInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            info: info.player,
            teamId: teamId,
            stats: stats,
            lastGame: response.lastGame,
            lastGamePlayerStats: lastGamePlayerStats,
            nextGame: response.nextGame
        )
    }
    
    func mlbPlayerStatsConverter(response: MLBPlayerInfoResponseModel) -> MLBPlayerStatsDisplayModel {
        let info = response.info!
        
        let stats = info.statistics.first { $0.type == "season" }
        var teamId: Int? {
            if let id = stats?.hitting?.team?.id {
                return id
            } else if let id = stats?.fielding?.team.id {
                return id
            } else if let id = stats?.catching?.team.id {
                return id
            } else if let id = stats?.pitching?.team.id {
                return id
            } else {
                return nil
            }
        }
        
        return MLBPlayerStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            player: info.player,
            teamId: teamId,
            stats: info.statistics
        )
    }
    
    func mlbPlayerStandingsConverter(response: MLBPlayerStandingsResponseModel) -> MLBPlayerStandingsDisplayModel {
        let standings: [MLBPlayerStandingsDisplay] = response.standings.compactMap { playerInfo in
            let player = playerInfo.player
            let statsList = playerInfo.statistics
            
            for item in statsList {
                if item.type == "season" {
                    return MLBPlayerStandingsDisplay(player: player, stats: item)
                }
            }
            
            return nil
        }
        
        return MLBPlayerStandingsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            standings: standings
        )
    }
    
    func mlbTeamInfoConverter(response: MLBTeamInfoResponseModel) -> MLBTeamInfoDisplayModel {
        let info = response.info!
        
        // TODO: statistics에 season정보 추가
//        let stats = info.statistics.first { $0.league.id == leagueId }
        
        return MLBTeamInfoDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            team: info.team,
            venue: info.venue,
            stats: info.statistics.first,
            lastGame: response.lastGame,
            nextGame: response.nextGame
        )
    }
    
    func mlbTeamStatsConverter(response: MLBTeamInfoResponseModel) -> MLBTeamStatsDisplayModel {
        let info = response.info!
        
        return MLBTeamStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            team: info.team,
            venue: info.venue,
            stats: info.statistics
        )
    }
    
    func mlbTeamStandingsConverter(response: MLBTeamStandingsResponseModel) -> MLBTeamStandingsDisplayModel {
        let standings: [MLBTeamStandingsDisplay] = response.standings.compactMap { teamInfo in
            let stats = teamInfo.statistics.first
            
            return MLBTeamStandingsDisplay(team: teamInfo.team, stats: stats!)
        }
        
        return MLBTeamStandingsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            standings: standings
        )
    }
    
    func mlbLeagueScheduleConverter(response: MLBGameScheduleResponseModel) -> MLBLeagueScheduleDisplayModel {
        let yearMonthList: [String] = response.scheduledMonths?.map {
            let components = $0.split(separator: "-")
            guard components.count == 2 else { return "" }
            
            return "\(components[0].suffix(2))/\(components[1])"
        } ?? []
        
        return MLBLeagueScheduleDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .league,
            yearMonthList: yearMonthList,
            games: response.schedule
        )
    }
    
    func mlbGameStatsConverter(response: MLBGameStatsResponseModel) -> MLBGameStatsDisplayModel {
        return MLBGameStatsDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            game: response.game!
        )
    }
    
    func mlbTournamentConverter(response: MLBGameScheduleResponseModel) -> MLBTournamentDisplayModel {
        return MLBTournamentDisplayModel(
            leagueId: leagueId ?? Constants.Ids.mlb,
            keywords: keywords,
            entityInfo: entityInfo,
            season: season,
            scheduleType: response.scheduleType ?? .tournamentBracket,
            games: response.schedule
        )
    }
    
    // Not used in DataModel
    // football
    static func fbGameToGameScheduleConverter(game: FBGame) -> FBGameForSchedule {
        let date = game.fixture.date.split(separator: "+").first
        let homeTeamId = game.teams.home.id
        let awayTeamId = game.teams.away.id
        let homeTeamScore = game.goals.home
        let awayTeamScore = game.goals.away
        let gameInfo = FBGameInfoForSchedule(
            round: game.league.round,
            elapsed: game.fixture.status.elapsed,
            homeTeamPenaltyScore: game.score.penalty._home, // TODO: Optional이 필요해서 임시로 _home, _away 사용. 추후 개선 필요.ㄸ
            awayTeamPenaltyScore: game.score.penalty._away
        )
        
        return FBGameForSchedule(
            itemKey: date != nil ? "\(date!)#\(game.fixture.id)" : "",
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
            homeTeamScore: homeTeamScore,
            awayTeamScore: awayTeamScore,
            gameStatus: game.fixture.status.short,
            gameInfo: gameInfo
        )
    }
    
    static func fbGameDisplayToLeagueScheduleDisplayConverter(
        gameStatsDisplayModel: FBGameStatsDisplayModel,
        leagueScheduleDisplayModel: FBLeagueScheduleDisplayModel
    ) -> FBLeagueScheduleDisplayModel {
        let game = gameStatsDisplayModel.game
        let newGames = leagueScheduleDisplayModel.games.map {
            $0.gameId == String(game.fixture.id) ? fbGameToGameScheduleConverter(game: game) : $0
        }
        
        var newDisplayModel = leagueScheduleDisplayModel
        newDisplayModel.games = newGames
        
        return newDisplayModel
    }
    
    // nba
    static func nbaGameListToGameScheduleListConverter(gameList: [NBAGame]) -> [NBAGameForSchedule] {
        return gameList.compactMap { game in
            return nbaGameToGameScheduleConverter(game: game)
        }
    }
    
    static func nbaGameToGameScheduleConverter(game: NBAGame) -> NBAGameForSchedule {
        let gameSummary = game.gameSummary
        let date = gameSummary?.date.split(separator: "+").first
        let homeTeamId = gameSummary?.homeTeamId
        let awayTeamId = gameSummary?.visitorTeamId
        let homeTeamScore = game.lineScore.first { $0.teamId == homeTeamId }?.pts ?? 0
        let awayTeamScore = game.lineScore.first { $0.teamId == awayTeamId }?.pts ?? 0
        
        return NBAGameForSchedule(
            itemKey: date != nil ? "\(date!)#\(gameSummary?.gameId ?? "")" : "",
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
            homeTeamScore: homeTeamScore,
            awayTeamScore: awayTeamScore,
            gameStatus: gameSummary != nil ? String(gameSummary!.gameStatusId) : nil,
            gameInfo: gameSummary
        )
    }
    
    static func nbaGameDisplayToLeagueScheduleDisplayConverter(
        gameStatsDisplayModel: NBAGameStatsDisplayModel,
        leagueScheduleDisplayModel: NBALeagueScheduleDisplayModel
    ) -> NBALeagueScheduleDisplayModel {
        let game = gameStatsDisplayModel.game
        let newGames = leagueScheduleDisplayModel.games.map {
            $0.gameId == game.gameSummary?.gameId ? ModelConverter.nbaGameToGameScheduleConverter(game: game) : $0
        }
        
        var newDisplayModel = leagueScheduleDisplayModel
        newDisplayModel.games = newGames
        
        return newDisplayModel
    }
    
    // mlb
    static func mlbGameToGameScheduleConverter(game: MLBGame) -> MLBGameForSchedule {
        let date = game.gameInfo.gameDate.split(separator: "+").first
        let homeTeamId = game.teams.home.id
        let awayTeamId = game.teams.away.id
        let homeTeamScore = game.linescore?.teams.home.runs
        let awayTeamScore = game.linescore?.teams.away.runs
        let gameInfo = MLBGameInfoForSchedule(
            currentInning: "\(game.linescore?.currentInning ?? 1)회\((game.linescore?.isTopInning ?? true) ? "초" : "말")",
            seriesDescription: game.game.seriesDescription,
            seriesStatus: game.game.seriesStatus
        )
        
        return MLBGameForSchedule(
            itemKey: date != nil ? "\(date!)#\(game.game.pk)" : "",
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
            homeTeamScore: homeTeamScore,
            awayTeamScore: awayTeamScore,
            gameStatus: game.status.detailedState,
            gameInfo: gameInfo
        )
    }
    
    static func mlbGameDisplayToLeagueScheduleDisplayConverter(
        gameStatsDisplayModel: MLBGameStatsDisplayModel,
        leagueScheduleDisplayModel: MLBLeagueScheduleDisplayModel
    ) -> MLBLeagueScheduleDisplayModel {
        let game = gameStatsDisplayModel.game
        let newGames = leagueScheduleDisplayModel.games.map {
            $0.gameId == String(game.game.pk) ? ModelConverter.mlbGameToGameScheduleConverter(game: game) : $0
        }
        
        var newDisplayModel = leagueScheduleDisplayModel
        newDisplayModel.games = newGames
        
        return newDisplayModel
    }
    
    static func mlbGameScheduleToGameConverter(game: MLBGameForSchedule) -> MLBGame {
        let gameData = MLBGameData(id: game.gameId)
        let gameInfo = MLBGameInfo(gameDate: game.date)
        let status = MLBGameStatus(detailedState: game.gameStatus)
        let teams = MLBGameTeams(away: MLBGameTeamDetail(id: game.awayTeamId), home: MLBGameTeamDetail(id: game.homeTeamId))
        
        return MLBGame(
            boxscore: nil,
            decisions: nil,
            game: gameData,
            gameInfo: gameInfo,
            linescore: nil,
            moundVisits: nil,
            probablePitchers: nil,
            review: nil,
            status: status,
            teams: teams,
            weather: nil
        )
    }
    
    // kbo
    static func kboGameToGameScheduleConverter(game: KBOGame) -> KBOGameForSchedule {
        let date = game.gameInfo?.date.split(separator: "+").first
        let homeTeamId = game.gameInfo?.homeTeamId ?? 0
        let awayTeamId = game.gameInfo?.awayTeamId ?? 0
        let homeTeamScore = game.lineScore?.home.r ?? "0"
        let awayTeamScore = game.lineScore?.away.r ?? "0"
        let gameInfo = KBOGameInfoForSchedule(currentInning: game.lineScore?.currentInning)
        
        return KBOGameForSchedule(
            itemKey: date != nil ? "\(date!)#\(game.gameInfo?.gameId ?? "")" : "",
            homeTeamId: Int(homeTeamId),
            awayTeamId: Int(awayTeamId),
            homeTeamScore: Int(homeTeamScore),
            awayTeamScore: Int(awayTeamScore),
            gameStatus: game.gameInfo?.gameStatus,
            gameInfo: gameInfo
        )
    }
    
    static func kboGameDisplayToLeagueScheduleDisplayConverter(
        gameStatsDisplayModel: KBOGameStatsDisplayModel,
        leagueScheduleDisplayModel: KBOLeagueScheduleDisplayModel
    ) -> KBOLeagueScheduleDisplayModel {
        let game = gameStatsDisplayModel.game
        let itemKey = "\(game.gameInfo?.date.split(separator: "+").first ?? "")#\(game.gameInfo?.gameId ?? "")"
        let newGames = leagueScheduleDisplayModel.games.map {
            $0.itemKey == itemKey ? ModelConverter.kboGameToGameScheduleConverter(game: game) : $0
        }
        
        var newDisplayModel = leagueScheduleDisplayModel
        newDisplayModel.games = newGames
        
        return newDisplayModel
    }
    
    static func kboGameScheduleToGameConverter(game: KBOGameForSchedule) -> KBOGame {
        let gameInfo = KBOGameInfo(
            awayTeamId: game.awayTeamId,
            date: game.date,
            gameId: game.gameId,
            homeTeamId: game.homeTeamId,
            remark: nil,
            gameStatus: game.gameStatus
        )
        
        return KBOGame(gameInfo: gameInfo, lineScore: nil, lineup: nil)
    }
}
