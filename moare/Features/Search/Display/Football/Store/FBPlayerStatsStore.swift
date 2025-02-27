//
//  FBPlayerStatsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation

import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerStatsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBPlayerStatsDisplayModel? = nil
        var statsList: [FBPlayerStats] = []
        var player: FBPlayerInfo? = nil
        var team: FBTeamInfo? = nil
        var nationalityKrName = ""
    }
    
    enum Action {
        case initData(displayModel: FBPlayerStatsDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                state.player = displayModel.player
                state.statsList = displayModel.stats
                state.team = displayModel.team
                state.nationalityKrName = EnNameTranslationUtility.translateByDic(type: .country, input: displayModel.player.nationality)
                
                return .none
            }
        }
    }
}
