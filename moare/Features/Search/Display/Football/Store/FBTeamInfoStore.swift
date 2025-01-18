//
//  FBTeamInfoStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamInfoStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        let displayModel: FBTeamInfoDisplayModel
        let team: FBTeamInfo
        let venue: FBVenue
        var league: FBLeague? = nil
        var stats: FBTeamStats? = nil
        var lastGame: FBGame? = nil
        var nextGame: FBGame? = nil
    }
    
    enum Action {
        case initData
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                let displayModel = state.displayModel
                
                state.league = displayModel.stats?.league
                state.stats = displayModel.stats
                state.lastGame = displayModel.lastGame
                state.nextGame = displayModel.nextGame
                
                return .none
            }
        }
    }
}
