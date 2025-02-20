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
        let displayModel: FBTeamScheduleDisplayModel
        let games: [FBGame]
        
        /* ---------------------
           ui state
           --------------------- */
        var isAllResultOpened = false
        var gameResultOpenedStateList: [Int: Bool] = [:]
    }
    
    enum Action {
        case initData
        case toggleAllResult
        case updateResultOpenedState(fixtureId: Int, isOpened: Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                let displayModel = state.displayModel
                
                state.games.forEach { value in
                    state.gameResultOpenedStateList[value.fixture.id] = false
                }
                
                return .none
                
            case .toggleAllResult:
                let newState = !state.isAllResultOpened
                state.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let fixtureId, let isOpened):
                state.gameResultOpenedStateList[fixtureId] = isOpened
                
                return .none
            }
        }
    }
}
