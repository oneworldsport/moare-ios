//
//  FBTeamInfoStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamInfoStore {
    typealias BaseInfo = BaseInfoStore<FBTeamInfoDisplayModel>
    
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
