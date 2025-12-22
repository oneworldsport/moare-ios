//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBAGameStatsStore {
    typealias BaseGameStats = BaseGameStatsStore<NBAGameStatsDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let firstCategoryItemHeight: CGFloat = 30
        let secondCategoryItemHeight: CGFloat = 36
        let itemWidth: CGFloat = 70
        let firstCategoryFontSize: CGFloat = 14
        let secondCategoryFontSize: CGFloat = 13
        let dataFontSize: CGFloat = 14
        let barWidth: CGFloat = 2
        let lineScoreItemHeight: CGFloat = 50
        let teamButtonWidth: CGFloat = 120
        
        /* ---------------------
           data state
           --------------------- */
        var baseGameStats: BaseGameStats.State

        var homeTeamLineScore: NBALineScore? = nil
        var awayTeamLineScore: NBALineScore? = nil
        var playerStats: [NBABoxScoreTeamPlayer] = []
        var playersTotalStats: NBAGameBoxScoreStats? = nil
        
        var homeTeamId = 0
        var awayTeamId = 0
        
        init(displayModel: NBAGameStatsDisplayModel) {
            self.baseGameStats = BaseGameStats.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseGameStats(BaseGameStats.Action)
        
        case sortPlayers
        case setPlayersTotalStats
        case refreshGame(shouldFetch: Bool = true)
        case updateDisplayModel(model: SportDecodableModel)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case didRefreshGame(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseGameStats, action: \.baseGameStats) { BaseGameStats() }
        
        Reduce { state, action in
            switch action {
            case .baseGameStats(.initData):
                // init with default value
                state.playerStats = []
                state.playersTotalStats = nil
                
                let displayModel = state.baseGameStats.displayModel
                
                if let gameSummary = displayModel.game.gameSummary {
                    state.homeTeamId = gameSummary.homeTeamId
                    state.awayTeamId = gameSummary.awayTeamId
                }
                
                // set lineScore
                state.homeTeamLineScore = displayModel.game.lineScore?.first { $0.teamId == state.homeTeamId }
                state.awayTeamLineScore = displayModel.game.lineScore?.first { $0.teamId == state.awayTeamId }
                
                if let _ = displayModel.game.boxScoreTraditional {
                    // set current(home) team's players stats
                    return .send(.baseGameStats(.selectTeam(isInit: true, index: 0)))
                }
                
                return .none
                
            case let .baseGameStats(.selectTeam(isInit, index)):
                
                // set selected team's players stats
                state.playerStats = if index == 0 {
                    state.baseGameStats.displayModel.game.boxScoreTraditional?.homeTeam.players ?? []
                } else {
                    state.baseGameStats.displayModel.game.boxScoreTraditional?.awayTeam.players ?? []
                }
                
                return .run { send in
                    await send(.sortPlayers)
                    await send(.setPlayersTotalStats)
                    if isInit {
                        await send(.refreshGame(shouldFetch: false))
                    }
                }
                
            case .baseGameStats(.selectFirstCategory):
                return .send(.sortPlayers)
                
            case .sortPlayers:
                switch state.baseGameStats.firstCategorySelectedIndex {
                case 0:
                    state.playerStats.sort { $0.statistics.points > $1.statistics.points }
                case 1:
                    state.playerStats.sort { $0.statistics.assists > $1.statistics.assists }
                case 2:
                    state.playerStats.sort { $0.statistics.reboundsOffensive > $1.statistics.reboundsOffensive }
                case 3:
                    state.playerStats.sort { $0.statistics.fieldGoalsAttempted > $1.statistics.fieldGoalsAttempted }
                case 4:
                    state.playerStats.sort { $0.statistics.fieldGoalsMade > $1.statistics.fieldGoalsMade }
                case 5:
                    state.playerStats.sort { $0.statistics.fieldGoalsPercentage > $1.statistics.fieldGoalsPercentage }
                case 6:
                    state.playerStats.sort { $0.statistics.threePointersAttempted > $1.statistics.threePointersAttempted }
                case 7:
                    state.playerStats.sort { $0.statistics.threePointersMade > $1.statistics.threePointersMade }
                case 8:
                    state.playerStats.sort { $0.statistics.threePointersPercentage > $1.statistics.threePointersPercentage }
                case 9:
                    state.playerStats.sort { $0.statistics.freeThrowsAttempted > $1.statistics.freeThrowsAttempted }
                case 10:
                    state.playerStats.sort { $0.statistics.freeThrowsMade > $1.statistics.freeThrowsMade }
                case 11:
                    state.playerStats.sort { $0.statistics.freeThrowsPercentage > $1.statistics.freeThrowsPercentage }
                case 12:
                    state.playerStats.sort { $0.statistics.reboundsDefensive > $1.statistics.reboundsDefensive }
                case 13:
                    state.playerStats.sort { $0.statistics.blocks > $1.statistics.blocks }
                case 14:
                    state.playerStats.sort { $0.statistics.steals > $1.statistics.steals }
                case 15:
                    state.playerStats.sort { $0.statistics.reboundsTotal > $1.statistics.reboundsTotal }
                case 16:
                    state.playerStats.sort { $0.statistics.turnovers > $1.statistics.turnovers }
                case 17:
                    state.playerStats.sort { $0.statistics.foulsPersonal > $1.statistics.foulsPersonal }
                case 18:
                    state.playerStats.sort { $0.statistics.plusMinusPoints > $1.statistics.plusMinusPoints }
                case 19:
                    state.playerStats.sort { CalendarUtil.formatHourMinuteToMinutes(time: $0.statistics.minutes) > CalendarUtil.formatHourMinuteToMinutes(time: $1.statistics.minutes) }
                default: break
                }
                
                return .none
                
            case .setPlayersTotalStats:
                var playersTotalStats = state.playerStats
                    .compactMap { $0.statistics }
                    .reduce(
                        NBAGameBoxScoreStats()
                    ) { acc, stats in
                        let assists = acc.assists + stats.assists
                        let blocks = acc.blocks + stats.blocks
                        let fieldGoalsAttempted = acc.fieldGoalsAttempted + stats.fieldGoalsAttempted
                        let fieldGoalsMade = acc.fieldGoalsMade + stats.fieldGoalsMade
                        let foulsPersonal = acc.foulsPersonal + stats.foulsPersonal
                        let freeThrowsAttempted = acc.freeThrowsAttempted + stats.freeThrowsAttempted
                        let freeThrowsMade = acc.freeThrowsMade + stats.freeThrowsMade
                        let minutes = CalendarUtil.formatMinutesToHourMinute(min: CalendarUtil.formatHourMinuteToMinutes(time: acc.minutes) + CalendarUtil.formatHourMinuteToMinutes(time: stats.minutes))
                        let points = acc.points + stats.points
                        let reboundsDefensive = acc.reboundsDefensive + stats.reboundsDefensive
                        let reboundsOffensive = acc.reboundsOffensive + stats.reboundsOffensive
                        let reboundsTotal = acc.reboundsTotal + stats.reboundsTotal
                        let steals = acc.steals + stats.steals
                        let threePointersAttempted = acc.threePointersAttempted + stats.threePointersAttempted
                        let threePointersMade = acc.threePointersMade + stats.threePointersMade
                        let turnovers = acc.turnovers + stats.turnovers
                        
                        return NBAGameBoxScoreStats(
                            assists: assists,
                            blocks: blocks,
                            fieldGoalsAttempted: fieldGoalsAttempted,
                            fieldGoalsMade: fieldGoalsMade,
                            foulsPersonal: foulsPersonal,
                            freeThrowsAttempted: freeThrowsAttempted,
                            freeThrowsMade: freeThrowsMade,
                            minutes: minutes,
                            points: points,
                            reboundsDefensive: reboundsDefensive,
                            reboundsOffensive: reboundsOffensive,
                            reboundsTotal: reboundsTotal,
                            steals: steals,
                            threePointersAttempted: threePointersAttempted,
                            threePointersMade: threePointersMade,
                            turnovers: turnovers
                        )
                    }
                
                playersTotalStats.fieldGoalsPercentage = playersTotalStats.fieldGoalsAttempted > 0 ? Double(playersTotalStats.fieldGoalsMade) / Double(playersTotalStats.fieldGoalsAttempted).rounded(to: 3) : 0.0
                
                playersTotalStats.freeThrowsPercentage = playersTotalStats.freeThrowsAttempted > 0 ? Double(playersTotalStats.freeThrowsMade) / Double(playersTotalStats.freeThrowsAttempted).rounded(to: 3) : 0.0
                
                playersTotalStats.threePointersPercentage = playersTotalStats.threePointersAttempted > 0 ? Double(playersTotalStats.threePointersMade) / Double(playersTotalStats.threePointersAttempted).rounded(to: 3) : 0.0
                
                playersTotalStats.plusMinusPoints = state.baseGameStats.teamCategorySelectedIndex == 0 ? (state.homeTeamLineScore?.pts ?? 0) - (state.awayTeamLineScore?.pts ?? 0) : (state.awayTeamLineScore?.pts ?? 0) - (state.homeTeamLineScore?.pts ?? 0)
                
                state.playersTotalStats = playersTotalStats
                
                return .none
                
            case let .refreshGame(shouldFetch):
                if shouldFetch {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        do {
                            let game = displayModel.game
                            if let gameSummary = game.gameSummary,
                               let boxScoreTraditional = game.boxScoreTraditional {
                                let result = try await searchClient.fetchById(
                                    season: displayModel.season,
                                    category: "basketball",
                                    date: gameSummary.gameDate,
                                    dataType: "basketball_game_stats",
                                    leagueId: Constants.Ids.nba,
                                    id: boxScoreTraditional.gameId
                                )
                                
                                await send(.updateDisplayModel(model: result.data))
                                await send(.delegate(.didRefreshGame(model: result.data)))
                            }
                        } catch {
                            print("\(error)")
                        }
                    }
                } else {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        let responseModel = NBAGameStatsResponseModel(game: displayModel.game)
                        let dataModel: SportDecodableModel = .nbaGameStats(responseModel, displayModel)
                            
                        await send(.delegate(.didRefreshGame(model: dataModel)))
                    }
                }
                
            case let .updateDisplayModel(model):
                if case .nbaGameStats(_, let displayModel) = model {
                    state.baseGameStats.displayModel = displayModel
                    
                    return .send(.baseGameStats(.initData))
                } else {
                    return .none
                }
                
            case .baseGameStats:
                return .none
                
            case .delegate:
                return .none
            } // switch action
        }
    }
}
