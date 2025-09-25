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
                let dataModel: SportDecodableModel = .kboPlayerStats(
                    state.responseModel,
                    ModelConverter.shared.kboPlayerStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showPlayerStats(model: dataModel)))
                
            case let .showGameStats(isPrevious):
                let responseModel = isPrevious ? KBOGameStatsResponseModel(game: state.responseModel.lastGame) : KBOGameStatsResponseModel(game: state.responseModel.nextGame)
                
                let dataModel: SportDecodableModel = .kboGameStats(
                    responseModel,
                    ModelConverter.shared.kboGameStatsConverter(response: responseModel)
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
