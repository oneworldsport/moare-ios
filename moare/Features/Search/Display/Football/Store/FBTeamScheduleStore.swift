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
    }
    
    enum Action {
        case initData
        case toggleAllResult
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                let displayModel = state.displayModel
                
                return .none
                
            case .toggleAllResult:
                state.isAllResultOpened.toggle()
                
                return .none
                
            }
        }
    }
}
