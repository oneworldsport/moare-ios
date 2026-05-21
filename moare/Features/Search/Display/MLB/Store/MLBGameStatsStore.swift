//
//  MLBGameStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBGameStatsStore {
    typealias BaseGameStats = BaseGameStatsStore<MLBGameStatsDisplayModel>
    
    @Dependency(\.searchClient) var searchClient
    
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
        
        var teamBoxScore: MLBGameBoxscoreTeamData? = nil
        var teamHitters: [(String, MLBGameBoxscoreTeamPlayer)] = []
        var teamPitchers: [(String, MLBGameBoxscoreTeamPlayer)] = []
//        var playersTotalStats: NBAGameBoxScoreStats? = nil
        
        init(displayModel: MLBGameStatsDisplayModel) {
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
                state.teamBoxScore = nil
                state.teamHitters = []
                state.teamPitchers = []
//                state.playersTotalStats = nil
                
                return .send(.baseGameStats(.selectTeam(isInit: true, index: 0)))
                
            case let .baseGameStats(.selectTeam(isInit, index)):
                // set selected team's boxscore
                state.teamBoxScore = if index == 0 {
                    state.baseGameStats.displayModel.game.boxscore?.teams.home
                } else {
                    state.baseGameStats.displayModel.game.boxscore?.teams.away
                }
                
                state.teamHitters = state.teamBoxScore?.players
                    .filter { !$0.value.battingOrder.isEmpty }
                    .map { ($0.key, $0.value) } ?? []
                
                
                state.teamPitchers = state.teamBoxScore?.players
                    .filter { ($0.value.position?.abbreviation == "P" && !$0.value.allPositions.isEmpty) ||
                        $0.value.allPositions.contains { $0.abbreviation == "P" } }
                    .map { ($0.key, $0.value) } ?? []
                
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
                    state.teamHitters.sort { ($0.1.stats?.batting?.atBats ?? 0) > ($1.1.stats?.batting?.atBats ?? 0) }
                case 1:
                    state.teamHitters.sort { ($0.1.stats?.batting?.hits ?? 0) > ($1.1.stats?.batting?.hits ?? 0) }
                case 2:
                    state.teamHitters.sort { ($0.1.stats?.batting?.homeRuns ?? 0) > ($1.1.stats?.batting?.homeRuns ?? 0) }
                case 3:
                    state.teamHitters.sort { ($0.1.stats?.batting?.rbi ?? 0) > ($1.1.stats?.batting?.rbi ?? 0) }
                case 4:
                    state.teamHitters.sort { ($0.1.stats?.batting?.runs ?? 0) > ($1.1.stats?.batting?.runs ?? 0) }
                case 5:
                    state.teamHitters.sort { ($0.1.stats?.batting?.stolenBases ?? 0) > ($1.1.stats?.batting?.stolenBases ?? 0) }
                case 6:
                    state.teamHitters.sort { ($0.1.stats?.batting?.baseOnBalls ?? 0) > ($1.1.stats?.batting?.baseOnBalls ?? 0) }
                case 7:
                    state.teamHitters.sort { ($0.1.stats?.batting?.strikeOuts ?? 0) > ($1.1.stats?.batting?.strikeOuts ?? 0) }
                case 8:
                    state.teamHitters.sort { (Double($0.1.stats?.batting?.avg ?? "0") ?? 0) > (Double($1.1.stats?.batting?.avg ?? "0") ?? 0) }
                default: break
                }
                
                return .none
                
            case .sortPitchers:
                switch state.baseGameStats.secondCategorySelectedIndex {
                case 0:
                    state.teamPitchers.sort { (Double($0.1.stats?.pitching?.inningsPitched ?? "0") ?? 0) > (Double($1.1.stats?.pitching?.inningsPitched ?? "0") ?? 0) }
                case 1:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.runs ?? 0) > ($1.1.stats?.pitching?.runs ?? 0) }
                case 2:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.earnedRuns ?? 0) > ($1.1.stats?.pitching?.earnedRuns ?? 0) }
                case 3:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.baseOnBalls ?? 0) > ($1.1.stats?.pitching?.baseOnBalls ?? 0) }
                case 4:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.strikeOuts ?? 0) > ($1.1.stats?.pitching?.strikeOuts ?? 0) }
                case 5:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.hits ?? 0) > ($1.1.stats?.pitching?.hits ?? 0) }
                case 6:
                    state.teamPitchers.sort { (Double($0.1.stats?.pitching?.era ?? "0.0") ?? 0) < (Double($1.1.stats?.pitching?.era ?? "0.0") ?? 0) }
                default: break
                }
                
                return .none
                
            case .sortByBattingOrder:
                state.teamHitters.sort { Int($0.1.battingOrder.prefix(1)) ?? 0 < Int($1.1.battingOrder.prefix(1)) ?? 0 }
                return .send(.baseGameStats(.selectFirstCategory(-1)))
                
            case .sortByPitcherOrder:
                // 투수 출전 순서 리스트
                let pitchersOrder = state.teamBoxScore?.pitchers ?? []
                
                // 투수 id 검색으로 인덱스를 알아내기 위해서
                let orderMap = Dictionary(
                    uniqueKeysWithValues: pitchersOrder.enumerated().map { ($1, $0) }
                ) // enumerated() 로 (index, value) 형태로 만들고 나서 map 으로 (value, index) 형태로 바꿔줌, 빠른 검색을 위해 Dictionary 로 만들어서 사용 -> value로 검색해서 index 값을 알아내기 위해
                
                state.teamPitchers = state.teamPitchers.sorted { first, second in // 리스트에서 요소 2개 비교
                    // "ID621107" → 621107
                    let firstId = Int(first.0.filter { $0.isNumber })
                    let secondId = Int(second.0.filter { $0.isNumber })
                    
                    return (orderMap[firstId ?? -1] ?? Int.max) < (orderMap[secondId ?? -1] ?? Int.max)
                }
                 
                return .send(.baseGameStats(.selectSecondCategory(-1)))
                
            case .setPlayersTotalStats:
                return .none
                
            case let .refreshGame(shouldFetch):
                if shouldFetch {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        let game = displayModel.game
                        
                        let result = try await searchClient.fetchById(
                            displayModel.season,
                            "baseball",
                            game.gameInfo.gameDate,
                            "baseball_game_stats",
                            Constants.Ids.mlb,
                            String(game.game.pk)
                        )
                        
                        await send(.updateDisplayModel(model: result.data))
                        await send(.delegate(.didRefreshGame(model: result.data)))
                    }
                } else {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        let responseModel = MLBGameStatsResponseModel(game: displayModel.game)
                        let dataModel: SportDecodableModel = .mlbGameStats(responseModel, displayModel)
                            
                        await send(.delegate(.didRefreshGame(model: dataModel)))
                    }
                }
                
            case let .updateDisplayModel(model):
                if case .mlbGameStats(_, let displayModel) = model {
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
