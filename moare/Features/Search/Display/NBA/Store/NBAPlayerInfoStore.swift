//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBAPlayerInfoStore {
    typealias BaseInfo = BaseInfoStore<NBAPlayerInfoDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 30
        
        /* ---------------------
           data state
           --------------------- */
        var baseInfo = BaseInfo.State()
    }
    
    enum Action {
        case baseInfo(BaseInfo.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseInfo, action: \.baseInfo) {
            BaseInfo()
        }
    }
}
