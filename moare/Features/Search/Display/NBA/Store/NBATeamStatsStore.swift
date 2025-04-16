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
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBATeamStatsDisplayModel? = nil
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: NBATeamStatsDisplayModel)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                
                state.teamNameDictionary = nameProvider.getDictionary(category: "nba_team")
                
                return .none
            }
        }
    }
}
