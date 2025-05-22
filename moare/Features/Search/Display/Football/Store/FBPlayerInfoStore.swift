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
