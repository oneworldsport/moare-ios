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
        
        let responseModel: FBPlayerInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: FBPlayerInfoResponseModel, displayModel: FBPlayerInfoDisplayModel) {
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
                let dataModel: SportDecodableModel = .fbPlayerStats(
                    state.responseModel,
                    ModelConverter.shared.fbPlayerStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showPlayerStats(model: dataModel)))
                
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
