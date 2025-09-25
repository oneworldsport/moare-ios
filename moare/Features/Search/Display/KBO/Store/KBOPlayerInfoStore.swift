//
//  KBOPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOPlayerInfoStore {
    typealias BaseInfo = BaseInfoStore<KBOPlayerInfoDisplayModel>
    
    @ObservableState
    struct State {
        let responseModel: KBOPlayerInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: KBOPlayerInfoResponseModel, displayModel: KBOPlayerInfoDisplayModel) {
            self.responseModel = responseModel
            self.baseInfo = BaseInfo.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseInfo(BaseInfo.Action)
        
        case showPlayerStats
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showPlayerStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseInfo, action: \.baseInfo) { BaseInfo() }
        
        Reduce { state, action in
            switch action {
            case .showPlayerStats:
                let dataModel: SportDecodableModel = .kboPlayerStats(
                    state.responseModel,
                    ModelConverter.shared.kboPlayerStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showPlayerStats(model: dataModel)))
                
            case .baseInfo:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
