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
        let responseModel: MLBPlayerInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: MLBPlayerInfoResponseModel, displayModel: MLBPlayerInfoDisplayModel) {
            self.responseModel = responseModel
            self.baseInfo = BaseInfo.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseInfo(BaseInfo.Action)
        
        case showPlayerStats
        case showGameStats(isPrevious: Bool = true)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showPlayerStats(model: SportDecodableModel)
        case showGameStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseInfo, action: \.baseInfo) { BaseInfo() }
        
        Reduce { state, action in
            switch action {
            case .showPlayerStats:
                let dataModel: SportDecodableModel = .mlbPlayerStats(
                    state.responseModel,
                    ModelConverter.shared.mlbPlayerStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showPlayerStats(model: dataModel)))
                
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
