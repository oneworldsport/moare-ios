//
//  FBPlayerInfoStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerInfoStore {
    typealias BaseInfo = BaseInfoStore<FBPlayerInfoDisplayModel>
    
    @ObservableState
    struct State {
        let itemHeight: CGFloat = 30
        
        var baseInfo: BaseInfo.State
        
        init(displayModel: FBPlayerInfoDisplayModel) {
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
