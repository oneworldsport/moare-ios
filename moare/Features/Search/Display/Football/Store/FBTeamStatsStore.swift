//
//  FBTeamStatsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamStatsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBTeamStatsDisplayModel? = nil
        var statsList: [FBTeamStats] = []
        var team: FBTeamInfo? = nil
        var venue: FBVenue? = nil
    }
    
    enum Action {
        case initData(displayModel: FBTeamStatsDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                state.statsList = displayModel.stats
                state.team = displayModel.team
                state.venue = displayModel.venue

                return .none
            }
        }
    }
}
