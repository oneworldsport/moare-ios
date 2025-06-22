//
//  FBTeamScheduleStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/15/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamScheduleStore {
    typealias BaseSchedule = BaseScheduleStore<FBTeamScheduleDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 100
        
        /* ---------------------
           data state
           --------------------- */
        var baseSchedule = BaseSchedule.State()
        var games: [FBGameForSchedule] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var gameResultOpenedStateList: [String: Bool] = [:]
    }
    
    enum Action {
        case baseSchedule(BaseSchedule.Action)
        
        /* ---------------------
           view action
           --------------------- */
        case toggleAllResult
        case updateResultOpenedState(gameId: String, isOpened: Bool)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseSchedule, action: \.baseSchedule) {
            BaseSchedule()
        }
        
        Reduce { state, action in
            switch action {
            case .baseSchedule(.initData):
                // init data
                state.games = state.baseSchedule.displayModel?.games ?? []
                
                let gameResultOpenedStateList = (state.games).reduce(into: [:]) { $0[$1.gameId] = false }
                state.gameResultOpenedStateList = gameResultOpenedStateList
                
                return .none
                
            case .baseSchedule(_):
                return .none
                
            case .toggleAllResult:
                let newState = !state.baseSchedule.isAllResultOpened
                state.baseSchedule.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let gameId, let isOpened):
                state.gameResultOpenedStateList[gameId] = isOpened
                
                return .none
            } // switch action
        }
    }
}
