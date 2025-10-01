//
//  MLBTeamInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBTeamInfoStore {
    typealias BaseInfo = BaseInfoStore<MLBTeamInfoDisplayModel>
    
    @ObservableState
    struct State {
        let responseModel: MLBTeamInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: MLBTeamInfoResponseModel, displayModel: MLBTeamInfoDisplayModel) {
            self.responseModel = responseModel
            self.baseInfo = BaseInfo.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseInfo(BaseInfo.Action)
        
        case showTeamStats
        case showGameStats(isPrevious: Bool = true)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showTeamStats(model: SportDecodableModel)
        case showGameStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseInfo, action: \.baseInfo) { BaseInfo() }
        
        Reduce { state, action in
            switch action {
            case .showTeamStats:
                let dataModel: SportDecodableModel = .mlbTeamStats(
                    state.responseModel,
                    ModelConverter.shared.mlbTeamStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showTeamStats(model: dataModel)))
                
            case let .showGameStats(isPrevious):
                let responseModel = isPrevious ? MLBGameStatsResponseModel(game: state.responseModel.lastGame) : MLBGameStatsResponseModel(game: state.responseModel.nextGame)
                
                let dataModel: SportDecodableModel = .mlbGameStats(
                    responseModel,
                    ModelConverter.shared.mlbGameStatsConverter(response: responseModel)
                )
                
                return .send(.delegate(.showGameStats(model: dataModel)))
                
            case .baseInfo:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
