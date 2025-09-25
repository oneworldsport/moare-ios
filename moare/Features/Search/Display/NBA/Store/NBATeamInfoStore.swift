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
        let responseModel: NBATeamInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: NBATeamInfoResponseModel, displayModel: NBATeamInfoDisplayModel) {
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
                let dataModel: SportDecodableModel = .nbaTeamStats(
                    state.responseModel,
                    ModelConverter.shared.nbaTeamStatsConverter(response: state.responseModel)
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
