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
        var displayModel: FBTeamInfoDisplayModel? = nil
        var team: FBTeamInfo? = nil
        var venue: FBVenue? = nil
        var league: FBLeague? = nil
        var stats: FBTeamStats? = nil
        var lastGame: FBGame? = nil
        var nextGame: FBGame? = nil
    }
    
    enum Action {
        case initData(displayModel: FBTeamInfoDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                state.team = displayModel.team
                state.venue = displayModel.venue
                state.league = displayModel.stats?.league
                state.stats = displayModel.stats
                state.lastGame = displayModel.lastGame
                state.nextGame = displayModel.nextGame
                
                return .none
            }
        }
    }
}
