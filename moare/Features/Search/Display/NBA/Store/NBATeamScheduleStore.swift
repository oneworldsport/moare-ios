//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBATeamScheduleStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBATeamScheduleDisplayModel? = nil
        var games: [NBAGame] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var isAllResultOpened = false
        var gameResultOpenedStateList: [String: Bool] = [:]
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: NBATeamScheduleDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        case toggleAllResult
        case updateResultOpenedState(gameCode: String, isOpened: Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.isAllResultOpened = false
                
                // init data
                state.displayModel = displayModel
                state.games = displayModel.games
                
                let gameResultOpenedStateList = (state.games).reduce(into: [:]) { $0[$1.gameSummary?.gameCode ?? ""] = false }
                state.gameResultOpenedStateList = gameResultOpenedStateList
                
                return .none
                
            case .toggleAllResult:
                let newState = !state.isAllResultOpened
                state.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                return .none
                
            case .updateResultOpenedState(let gameCode, let isOpened):
                state.gameResultOpenedStateList[gameCode] = isOpened
                
                return .none
            } // switch action
        }
    }
}
