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
                if let displayModel = state.displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case Constants.Ids.epl:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                    case Constants.Ids.laliga:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                    case Constants.Ids.bundesliga:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                    case Constants.Ids.ligue1:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.ligue1PlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                    case Constants.Ids.seriea:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.serieaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                    case Constants.Ids.mls:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlsPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
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
