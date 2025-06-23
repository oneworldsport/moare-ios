//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBATeamInfoStore {
    typealias BaseInfo = BaseInfoStore<NBATeamInfoDisplayModel>
    
    @ObservableState
    struct State {
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
