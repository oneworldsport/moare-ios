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
        var displayModel: T
        
        /* ---------------------
           ui state
           --------------------- */
        var headerCategorySelectedIndex = 0
        var categorySelectedIndex = 0
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
        
        init(displayModel: T) {
            self.displayModel = displayModel
        }
    }
    
    enum Action {
        case initData
        case selectCategory(index: Int)
        case selectHeaderCategory(index: Int, isInit: Bool = false)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                // init with default value
                state.headerCategorySelectedIndex = 0
                state.categorySelectedIndex = 0
                
                state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                var teamStandingsCategories = StringConstants.Football.teamStandingsCategories
                
                if let displayModel = state.displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case Constants.Ids.nba:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.nbaTeamDic)
                        teamStandingsCategories = StringConstants.NBA.teamStandingsCategories
                    case Constants.Ids.kbo:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.kboTeamDic)
                        teamStandingsCategories = StringConstants.KBO.teamStandingsCategories
                    case Constants.Ids.mlb:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbTeamDic)
                        teamStandingsCategories = StringConstants.MLB.teamStandingsCategories
                    default: break
                    }
                    
                    let keywords = displayModel.keywords
                    if !keywords.isEmpty {
                        let index = teamStandingsCategories.firstIndex { category in
                            let keyword = keywords.first { $0.keyword == category }
                            return keyword != nil
                        }
                        
                        if let index {
                            state.categorySelectedIndex = index
                        }
                    }
                }
                
                return .none
                
            case .selectCategory(let index):
                state.categorySelectedIndex = index
                
                return .none
                
            case .selectHeaderCategory(_, _):
                return .none
            }
        }
    }
}
