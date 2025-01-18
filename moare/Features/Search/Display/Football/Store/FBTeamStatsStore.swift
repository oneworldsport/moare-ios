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
        let displayModel: FBTeamStatsDisplayModel
        let statsList: [FBTeamStats]
        let team: FBTeamInfo
        let venue: FBVenue
    }
    
    enum Action {
        case initData
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                let displayModel = state.displayModel

                return .none
            }
        }
    }
}
