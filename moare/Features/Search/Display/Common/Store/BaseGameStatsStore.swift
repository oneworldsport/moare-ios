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
        var displayModel: T
        var displayDataState: ApiFetchState = ApiFetchState.idle
        
        /* ---------------------
           ui state
           --------------------- */
        var firstCategorySelectedIndex = 0
        var secondCategorySelectedIndex = 0
        var teamCategorySelectedIndex = 0
        var shouldScrollCategory = false
        
        /* ---------------------
           etc
           --------------------- */
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
        
        init(displayModel: T) {
            self.displayModel = displayModel
        }
    }
    
    enum Action {
        case initData
        case selectFirstCategory(Int)
        case selectSecondCategory(Int)
        case selectTeam(isInit: Bool = false, index: Int)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                // init with default value
                state.displayDataState = .idle
                
                state.firstCategorySelectedIndex = 0
                state.secondCategorySelectedIndex = 0
                state.teamCategorySelectedIndex = 0
                state.shouldScrollCategory = false
                
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
                
            case .selectFirstCategory(let index):
                state.shouldScrollCategory =  false
                state.firstCategorySelectedIndex = index
                
                return .none
                
            case .selectSecondCategory(let index):
                state.shouldScrollCategory = false
                state.secondCategorySelectedIndex = index
                
                return .none
                
            case .selectTeam(_, let index):
                state.teamCategorySelectedIndex = index
                
                return .none
            }
        }
    }
}
