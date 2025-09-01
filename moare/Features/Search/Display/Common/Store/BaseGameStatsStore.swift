//
//  BaseGameStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BaseGameStatsStore<T> {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: T? = nil
        var displayDataState: ApiFetchState = ApiFetchState.idle
        
        /* ---------------------
           ui state
           --------------------- */
        var firstCategorySelectedIndex = 0
        var secondCategorySelectedIndex = 0
        var selectedTeamIndex = 0
        var shouldScrollCategory = false
        
        /* ---------------------
           etc
           --------------------- */
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: T)
        case selectFirstCategory(Int)
        case selectSecondCategory(Int)
        case selectTeam(Int)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.displayDataState = .idle
                
                state.firstCategorySelectedIndex = 0
                state.secondCategorySelectedIndex = 0
                state.selectedTeamIndex = 0
                state.shouldScrollCategory = false
                
                // init data
                state.displayModel = displayModel
                
                if let displayModel = displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case Constants.Ids.epl:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplTeamDic)
                    case Constants.Ids.laliga:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaTeamDic)
                    case Constants.Ids.bundesliga:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                    case Constants.Ids.ligue1:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.ligue1PlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.ligue1TeamDic)
                    case Constants.Ids.seriea:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.serieaPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.serieaTeamDic)
                    case Constants.Ids.mls:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlsPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlsTeamDic)
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
                
            case .selectFirstCategory(let index):
                state.shouldScrollCategory =  true
                state.firstCategorySelectedIndex = index
                
                return .none
                
            case .selectSecondCategory(let index):
                state.shouldScrollCategory = false
                state.secondCategorySelectedIndex = index
                
                return .none
                
            case .selectTeam(let index):
                state.selectedTeamIndex = index
                
                return .none
            }
        }
    }
}
