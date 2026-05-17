//
//  TennisGameStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 1/27/26.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct TennisGameStatsStore {
    typealias BaseGameStats = BaseGameStatsStore<TennisGameStatsDisplayModel>
    
    @Dependency(\.searchClient) var searchClient
    
    @ObservableState
    struct State {
        var baseGameStats: BaseGameStats.State
        
        var isDoubles = false
        
        init(displayModel: TennisGameStatsDisplayModel) {
            self.baseGameStats = BaseGameStats.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseGameStats(BaseGameStats.Action)
        
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
                state.isDoubles = false
                
                let tournament = state.baseGameStats.displayModel.game.gameInfo.tournament
                
                if tournament?.slug.contains("doubles") == true {
                    state.isDoubles = true
                }
                
                return .none
                
            case let .refreshGame(shouldFetch):
                let displayModel = state.baseGameStats.displayModel
                
                if shouldFetch {
                    return .run { send in
                        do {
                            let gameInfo = displayModel.game.gameInfo
                            let result = try await searchClient.fetchById(
                                displayModel.season,
                                "tennis",
                                gameInfo.gameDate,
                                "tennis_game_stats",
                                displayModel.leagueId,
                                String(gameInfo.id)
                            )
                            
                            await send(.updateDisplayModel(model: result.data))
                            // TODO: updateDisplayModel > initData > selectTeam > refreshGame(false) 과정에서 didRefreshGame이 실행되니깐 굳이 여기서는 해줄 필요 없는듯?
//                            await send(.delegate(.didRefreshGame(model: result.data)))
                        } catch {
                            print("\(error)")
                        }
                    }
                } else {
                    return .run { send in
                        let responseModel = TennisGameStatsResponseModel(game: displayModel.game)
                        let dataModel: SportDecodableModel = .tennisGameStats(responseModel, displayModel)
                            
                        await send(.delegate(.didRefreshGame(model: dataModel)))
                    }
                }
                
            case let .updateDisplayModel(model):
                if case .tennisGameStats(_, let displayModel) = model {
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
