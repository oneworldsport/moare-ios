//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBAPlayerInfoStore {
    typealias BaseInfo = BaseInfoStore<NBAPlayerInfoDisplayModel>
    
    @ObservableState
    struct State {
        let itemHeight: CGFloat = 30
    
        let responseModel: NBAPlayerInfoResponseModel
        var baseInfo: BaseInfo.State
        
        init(responseModel: NBAPlayerInfoResponseModel, displayModel: NBAPlayerInfoDisplayModel) {
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
                let dataModel: SportDecodableModel = .nbaPlayerStats(
                    state.responseModel,
                    ModelConverter.shared.nbaPlayerStatsConverter(response: state.responseModel)
                )
                
                return .send(.delegate(.showPlayerStats(model: dataModel)))
                
            case let .showGameStats(isPrevious):
                let responseModel = isPrevious ? NBAGameStatsResponseModel(game: state.responseModel.lastGame) : NBAGameStatsResponseModel(game: state.responseModel.nextGame)
                
                let dataModel: SportDecodableModel = .nbaGameStats(
                    responseModel,
                    ModelConverter.shared.nbaGameStatsConverter(response: responseModel)
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
