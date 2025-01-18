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
        let displayModel: FBPlayerStatsDisplayModel
        let statsList: [FBPlayerStats]
        let player: FBPlayerInfo
        var team: FBTeamInfo? = nil
        var nationalityKrName = ""
    }
    
    enum Action {
        case initData
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                let displayModel = state.displayModel
                
                state.team = displayModel.team
                state.nationalityKrName = EnNameTranslationUtility.translateByDic(type: .country, input: state.player.nationality)
                
                return .none
            }
        }
    }
}
