//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBAPlayerInfoStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 30
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBAPlayerInfoDisplayModel? = nil
        
        /* ---------------------
           etc
           --------------------- */
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: NBAPlayerInfoDisplayModel)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                
                state.playerNameDictionary = nameProvider.getDictionary(category: "nba_player")
                state.teamNameDictionary = nameProvider.getDictionary(category: "nba_team")
                
                return .none
            }
        }
    }
}
