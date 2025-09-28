//
//  KBOPlayerStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOPlayerStatsStore {
    typealias BaseStats = BaseStatsStore<KBOPlayerStatsDisplayModel>
    
    @ObservableState
    struct State {
        var baseStats: BaseStats.State
        
        init(displayModel: KBOPlayerStatsDisplayModel) {
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
