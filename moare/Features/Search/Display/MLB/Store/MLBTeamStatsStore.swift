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
        var baseStats: BaseStats.State
        
        init(displayModel: MLBTeamStatsDisplayModel) {
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
