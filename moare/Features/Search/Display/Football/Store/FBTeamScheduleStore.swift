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
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 100
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBTeamScheduleDisplayModel? = nil
        var games: [FBGame] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var isAllResultOpened = false
        var gameResultOpenedStateList: [Int: Bool] = [:]
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: FBTeamScheduleDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        case toggleAllResult
        case updateResultOpenedState(fixtureId: Int, isOpened: Bool)
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
                
                let gameResultOpenedStateList = (state.games).reduce(into: [:]) { $0[$1.fixture.id] = false }
                state.gameResultOpenedStateList = gameResultOpenedStateList
                
                return .none
                
            case .toggleAllResult:
                let newState = !state.isAllResultOpened
                state.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let fixtureId, let isOpened):
                state.gameResultOpenedStateList[fixtureId] = isOpened
                
                return .none
            } // switch action
        }
    }
}
