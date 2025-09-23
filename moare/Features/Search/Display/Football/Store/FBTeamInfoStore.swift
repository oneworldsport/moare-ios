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
        var baseInfo: BaseInfo.State
        
        init(displayModel: FBTeamInfoDisplayModel) {
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
