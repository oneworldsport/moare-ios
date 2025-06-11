//
//  MLBTeamStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBTeamStatsStore {
    typealias BaseStats = BaseStatsStore<MLBTeamStatsDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var baseStats = BaseStats.State()
    }
    
    enum Action {
        case baseStats(BaseStats.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseStats, action: \.baseStats) {
            BaseStats()
        }
    }
}
