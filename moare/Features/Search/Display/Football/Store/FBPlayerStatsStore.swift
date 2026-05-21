//
//  FBPlayerStatsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation

import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerStatsStore {
    typealias BaseStats = BaseStatsStore<FBPlayerStatsDisplayModel>
    
    @ObservableState
    struct State {
        var baseStats: BaseStats.State
        
        var statsList: [FBPlayerStats] = []
        
        init(displayModel: FBPlayerStatsDisplayModel) {
            self.baseStats = BaseStats.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseStats(BaseStats.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseStats, action: \.baseStats) { BaseStats() }
        
        Reduce { state, action in
            switch action {
            case .baseStats(.initData):
                // 리그 기록을 제일 첫번째 아이템으로
                state.statsList = state.baseStats.displayModel.stats.sorted { a, b in
                    let aIsLeague = Constants.Ids.footballLeagues.contains(a.league.id)
                    let bIsLeague = Constants.Ids.footballLeagues.contains(b.league.id)
                    
                    if aIsLeague && !bIsLeague {
                        return true
                    } else if !aIsLeague && bIsLeague {
                        return false
                    } else {
                        return false
                    }
                }
                
                return .none
                
            case .baseStats:
                return .none
            }
        }
    }
}
