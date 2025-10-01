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
        let responseModel: FBTeamInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: FBTeamInfoResponseModel, displayModel: FBTeamInfoDisplayModel) {
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
                let dataModel: SportDecodableModel = .fbTeamStats(
                    state.responseModel,
                    ModelConverter.shared.fbTeamStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showTeamStats(model: dataModel)))
                
            case let .showGameStats(isPrevious):
                let responseModel = isPrevious ? FBGameStatsResponseModel(game: state.responseModel.lastGame) : FBGameStatsResponseModel(game: state.responseModel.nextGame)
                
                let dataModel: SportDecodableModel = .fbGameStats(
                    responseModel,
                    ModelConverter.shared.fbGameStatsConverter(response: responseModel)
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
