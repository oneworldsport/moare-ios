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
        var baseInfo: BaseInfo.State
        
        init(displayModel: NBATeamInfoDisplayModel) {
            self.baseInfo = BaseInfo.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseInfo(BaseInfo.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseInfo, action: \.baseInfo) { BaseInfo() }
    }
}
