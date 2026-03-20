//
//  BaseStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BaseStatsStore<T> {
    
    @ObservableState
    struct State {
        var displayModel: T
        
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
        
        init(displayModel: T) {
            self.displayModel = displayModel
        }
    }
    
    enum Action {
        case initData
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballPlayerDic)
                state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                
                if let displayModel = state.displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case Constants.Ids.nba:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.nbaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.nbaTeamDic)
                    case Constants.Ids.kbo:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.kboTeamDic)
                    case Constants.Ids.mlb:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbTeamDic)
                    default: break
                    }
                }
                
                return .none
            }
        }
    }
}
