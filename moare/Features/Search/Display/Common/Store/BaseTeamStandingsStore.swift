//
//  BaseTeamStandingsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BaseTeamStandingsStore<T> {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: T? = nil
        
        /* ---------------------
           ui state
           --------------------- */
        var secondCategorySelectedIndex = 0
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: T)
        case selectSecondCategory(Int)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.secondCategorySelectedIndex = 0
                
                // init data
                state.displayModel = displayModel
                
                if let displayModel = displayModel as? DisplayModelBase {
                    switch displayModel.leagueId {
                    case Constants.Ids.epl:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplTeamDic)
                    case Constants.Ids.laliga:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaTeamDic)
                    case Constants.Ids.bundesliga:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                    case Constants.Ids.ligue1:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.ligue1TeamDic)
                    case Constants.Ids.nba:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.nbaTeamDic)
                    case Constants.Ids.kbo:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.kboTeamDic)
                    case Constants.Ids.mlb:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbTeamDic)
                    default: break
                    }
                    
                    let keywords = displayModel.keywords
                    if !keywords.isEmpty {
                        let index = StringConstants.Football.teamStandingsCategories.firstIndex { category in
                            let keyword = keywords.first { $0.keyword == category }
                            return keyword != nil
                        }
                        
                        if let index {
                            state.secondCategorySelectedIndex = index
                        }
                    }
                }
                
                return .none
                
            case .selectSecondCategory(let index):
                state.secondCategorySelectedIndex = index
                
                return .none
            }
        }
    }
}
