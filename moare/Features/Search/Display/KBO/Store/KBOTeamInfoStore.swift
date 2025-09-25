//
//  KBOTeamInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOTeamInfoStore {
    typealias BaseInfo = BaseInfoStore<KBOTeamInfoDisplayModel>
    
    @ObservableState
    struct State {
        let responseModel: KBOTeamInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: KBOTeamInfoResponseModel, displayModel: KBOTeamInfoDisplayModel) {
            self.responseModel = responseModel
            self.baseInfo = BaseInfo.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseInfo(BaseInfo.Action)
        
        case showTeamStats
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showTeamStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseInfo, action: \.baseInfo) { BaseInfo() }
        
        Reduce { state, action in
            switch action {
            case .showTeamStats:
                let dataModel: SportDecodableModel = .kboTeamStats(
                    state.responseModel,
                    ModelConverter.shared.kboTeamStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showTeamStats(model: dataModel)))
                
            case .baseInfo:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
