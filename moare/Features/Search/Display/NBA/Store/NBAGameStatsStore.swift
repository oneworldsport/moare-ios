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
    
    @Dependency(\.searchClient) var searchClient
    
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
        case selectTitleCategory
        
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
                
                return .run { [firstCategorySelectedIndex = state.baseGameStats.firstCategorySelectedIndex] send in
                    if isInit {
                        // TODO: 새로고침으로 updateDisplayModel > initData > selectTeam이 실행됐을때도 선택했던 정렬이 유지되게?
                        await send(.refreshGame(shouldFetch: false))
                        await send(.selectTitleCategory)
                    } else {
                        if firstCategorySelectedIndex == -1 {
                            await send(.selectTitleCategory)
                        } else {
                            await send(.sortPlayers)
                        }
                    }
                    
                    await send(.setPlayersTotalStats)
                }
                
            case .baseGameStats(.selectFirstCategory):
                return .send(.sortPlayers)
                
            case .sortPlayers:
                switch state.baseGameStats.firstCategorySelectedIndex {
                case 0:
                    state.playerStats.sort { $0.statistics.seconds > $1.statistics.seconds }
                case 1:
                    state.playerStats.sort { $0.statistics.points > $1.statistics.points }
                case 2:
                    state.playerStats.sort { $0.statistics.assists > $1.statistics.assists }
                case 3:
                    state.playerStats.sort { $0.statistics.reboundsTotal > $1.statistics.reboundsTotal }
                case 5:
                    state.playerStats.sort { $0.statistics.fieldGoalsMade > $1.statistics.fieldGoalsMade }
                case 6:
                    state.playerStats.sort { $0.statistics.threePointersMade > $1.statistics.threePointersMade }
                case 7:
                    state.playerStats.sort { $0.statistics.freeThrowsMade > $1.statistics.freeThrowsMade }
                case 9:
                    state.playerStats.sort { $0.statistics.steals > $1.statistics.steals }
                case 10:
                    state.playerStats.sort { $0.statistics.blocks > $1.statistics.blocks }
                case 12:
                    state.playerStats.sort { $0.statistics.turnovers > $1.statistics.turnovers }
                case 13:
                    state.playerStats.sort { $0.statistics.foulsPersonal > $1.statistics.foulsPersonal }
                case 15:
                    state.playerStats.sort { $0.statistics.reboundsTotal > $1.statistics.reboundsTotal }
                case 16:
                    state.playerStats.sort { $0.statistics.plusMinusPoints > $1.statistics.plusMinusPoints }
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
                        let minutes = CalendarUtil.formatMinutesToHourMinute(min: CalendarUtil.formatMinuteSecondToSeconds(time: acc.minutes) + CalendarUtil.formatMinuteSecondToSeconds(time: stats.minutes))
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
                
            case .selectTitleCategory:
                // 선발, 후보를 먼저 정렬한 후 각각 출전시간 순으로 정렬
                state.playerStats.sort {
                    // 1) 선발/후보
                    if $0.starterSortKey != $1.starterSortKey {
                        return $0.starterSortKey < $1.starterSortKey
                    }
                    // 2) seconds 내림차순
                    return $0.statistics.seconds > $1.statistics.seconds
                }
                
                return .send(.baseGameStats(.selectFirstCategory(-1)))
                
            case let .refreshGame(shouldFetch):
                if shouldFetch {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        do {
                            let game = displayModel.game
                            if let gameSummary = game.gameSummary {
                                let result = try await searchClient.fetchById(
                                    displayModel.season,
                                    "basketball",
                                    gameSummary.gameDate,
                                    "basketball_game_stats",
                                    Constants.Ids.nba,
                                    gameSummary.gameId
                                )
                                
                                await send(.updateDisplayModel(model: result.data))
                                // TODO: updateDisplayModel > initData > selectTeam > refreshGame(false) 과정에서 didRefreshGame이 실행되니깐 굳이 여기서는 해줄 필요 없는듯?
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
