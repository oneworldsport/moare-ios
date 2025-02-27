//
//  FBPlayerInfoStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerInfoStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 30
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBPlayerInfoDisplayModel? = nil
        var player: FBPlayerInfo? = nil
        var stats: FBPlayerStats? = nil
        var team: FBTeamInfo? = nil
        var league: FBLeague? = nil
        var lastGame: FBGame? = nil
        var lastGamePlayerStats: FBGamePlayerStatsDetail? = nil
        var nextGame: FBGame? = nil
        var nationalityKrName = ""
    }
    
    enum Action {
        case initData(displayModel: FBPlayerInfoDisplayModel)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                state.player = displayModel.info
                
                state.stats = displayModel.stats
                state.team = state.stats?.team
                state.league = state.stats?.league
                state.lastGame = displayModel.lastGame
                state.lastGamePlayerStats = displayModel.lastGamePlayerStats
                state.nextGame = displayModel.nextGame
                state.nationalityKrName = EnNameTranslationUtility.translateByDic(type: .country, input: displayModel.info.nationality)
                
                return .none
            }
        }
    }
}
