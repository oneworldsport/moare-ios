//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBATeamStatsStore {
    typealias BaseStats = BaseStatsStore<NBATeamStatsDisplayModel>
    
    @ObservableState
    struct State {
        var baseStats: BaseStats.State
        
        init(displayModel: NBATeamStatsDisplayModel) {
            self.baseStats = BaseStats.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseStats(BaseStats.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseStats, action: \.baseStats) { BaseStats() }
    }
}
