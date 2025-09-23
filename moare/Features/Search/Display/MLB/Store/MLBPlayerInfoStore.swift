//
//  MLBPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBPlayerInfoStore {
    typealias BaseInfo = BaseInfoStore<MLBPlayerInfoDisplayModel>
    
    @ObservableState
    struct State {
        var baseInfo: BaseInfo.State
        
        init(displayModel: MLBPlayerInfoDisplayModel) {
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
