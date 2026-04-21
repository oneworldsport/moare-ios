//
//  KBOGameStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOGameStatsStore {
    typealias BaseGameStats = BaseGameStatsStore<KBOGameStatsDisplayModel>
    
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let lineScoreItemHeight: CGFloat = 50
        let teamButtonWidth: CGFloat = 120
        
        /* ---------------------
           data state
           --------------------- */
        var baseGameStats: BaseGameStats.State
        
        var teamLineup: KBOGameLineup? = nil
        var teamHitters: [KBOGameHitterStats] = []
        var teamPitchers: [KBOGamePitcherStats] = []
//        var playersTotalStats: NBAGameBoxScoreStats? = nil
        
        init(displayModel: KBOGameStatsDisplayModel) {
            self.baseGameStats = BaseGameStats.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseGameStats(BaseGameStats.Action)
        
        case sortHitters
        case sortPitchers
        case sortByBattingOrder
        case sortByPitcherOrder
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
                state.teamLineup = nil
                state.teamHitters = []
                state.teamPitchers = []
//                state.playersTotalStats = nil
                
                return .send(.baseGameStats(.selectTeam(isInit: true, index: 0)))
                
            case let .baseGameStats(.selectTeam(isInit, index)):
                // set selected team's boxscore
                state.teamLineup = if index == 0 {
                    state.baseGameStats.displayModel.game.lineup?.home
                } else {
                    state.baseGameStats.displayModel.game.lineup?.away
                }
                
                state.teamHitters = state.teamLineup?.hitters ?? []
                state.teamPitchers = state.teamLineup?.pitchers ?? []
                
                let firstCategorySelectedIndex = state.baseGameStats.firstCategorySelectedIndex
                let secondCategorySelectedIndex = state.baseGameStats.secondCategorySelectedIndex
                
                return .run { send in
                    if isInit {
                        await send(.sortHitters)
                        await send(.sortPitchers)
                        await send(.refreshGame(shouldFetch: false))
                    } else {
                        if firstCategorySelectedIndex == -1 {
                            await send(.sortByBattingOrder)
                        }
                        
                        if secondCategorySelectedIndex == -1 {
                            await send(.sortByPitcherOrder)
                        }
                    }
                    await send(.sortByBattingOrder)
                    await send(.sortByPitcherOrder)
                }
                
            case .baseGameStats(.selectFirstCategory):
                return .send(.sortHitters)
                
            case .baseGameStats(.selectSecondCategory):
                return .send(.sortPitchers)
                
            case .sortHitters:
                switch state.baseGameStats.firstCategorySelectedIndex {
                case 0:
                    state.teamHitters.sort { Double($0.ab) > Double($1.ab)}
                case 1:
                    state.teamHitters.sort { Double($0.h) > Double($1.h) }
                case 2:
                    state.teamHitters.sort { $0.homeRuns > $1.homeRuns }
                case 3:
                    state.teamHitters.sort { Double($0.rbi) > Double($1.rbi) }
                case 4:
                    state.teamHitters.sort { Double($0.r) > Double($1.r) }
                case 5:
                    state.teamHitters.sort { $0.baseOnBalls > $1.baseOnBalls }
                case 6:
                    state.teamHitters.sort { $0.strikeOuts > $1.strikeOuts }
                case 7:
                    state.teamHitters.sort { $0.groundIntoDoublePlay > $1.groundIntoDoublePlay }
                default: break
                }
                
                return .none
                
            case .sortPitchers:
                switch state.baseGameStats.secondCategorySelectedIndex {
                case 0:
                    state.teamPitchers.sort { (Double($0.ip) ?? 0) > (Double($1.ip) ?? 0) }
                case 1:
                    state.teamPitchers.sort { (Double($0.r) ?? 0) > (Double($1.r) ?? 0) }
                case 2:
                    state.teamPitchers.sort { (Double($0.er) ?? 0) > (Double($1.er) ?? 0) }
                case 3:
                    state.teamPitchers.sort { (Double($0.bb) ?? 0) > (Double($1.bb) ?? 0) }
                case 4:
                    state.teamPitchers.sort { (Double($0.so) ?? 0) > (Double($1.so) ?? 0) }
                case 5:
                    state.teamPitchers.sort { (Double($0.h) ?? 0) > (Double($1.h) ?? 0) }
                default: break
                }
                
                return .none
                
            case .sortByBattingOrder:
                state.teamHitters.sort { $0.battingNumber < $1.battingNumber }
                
                return .send(.baseGameStats(.selectFirstCategory(-1)))
                
            case .sortByPitcherOrder:
                let pitchersOrder = state.teamLineup?.pitchers ?? []
                
                let pitcherOrderMap = Dictionary(
                    uniqueKeysWithValues: pitchersOrder.enumerated().map { index, pitcher in
                        (pitcher.id, index)
                    }
                )
                
                // sort는 원본을 직접 바꿈
                state.teamPitchers.sort { first, second in
                    (pitcherOrderMap[first.id] ?? Int.max) < (pitcherOrderMap[second.id] ?? Int.max)
                }

                return .send(.baseGameStats(.selectSecondCategory(-1)))
                
            case .setPlayersTotalStats:
                return .none
                
            case let .refreshGame(shouldFetch):
                if shouldFetch {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        if let gameInfo = displayModel.game.gameInfo {
                            let result = try await searchClient.fetchById(
                                season: displayModel.season,
                                category: "baseball",
                                date: gameInfo.date,
                                dataType: "baseball_game_stats",
                                leagueId: Constants.Ids.kbo,
                                id: gameInfo.gameId
                            )
                            
                            await send(.updateDisplayModel(model: result.data))
                            await send(.delegate(.didRefreshGame(model: result.data)))
                        }
                    }
                } else {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        let responseModel = KBOGameStatsResponseModel(game: displayModel.game)
                        let dataModel: SportDecodableModel = .kboGameStats(responseModel, displayModel)
                            
                        await send(.delegate(.didRefreshGame(model: dataModel)))
                    }
                }
                
            case let .updateDisplayModel(model):
                if case .kboGameStats(_, let displayModel) = model {
                    state.baseGameStats.displayModel = displayModel
                    
                    return .send(.baseGameStats(.initData))
                } else {
                    return .none
                }
                
            case .baseGameStats:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
