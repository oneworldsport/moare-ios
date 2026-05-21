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
        case initNameDictionary([String: String])
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
                
                var teamStandingsCategories = StringConstants.Football.teamStandingsCategories
                if let displayModel = state.displayModel as? SportDisplayModel {
                    switch displayModel.leagueId {
                    case Constants.Ids.nba:
                        teamStandingsCategories = StringConstants.NBA.teamStandingsCategories
                    case Constants.Ids.kbo:
                        teamStandingsCategories = StringConstants.KBO.teamStandingsCategories
                    case Constants.Ids.mlb:
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
                
                return .run { [displayModel = state.displayModel] send in
                    var dic = await nameProvider.getDictionary(Constants.Keys.footballTeamDic)
                    
                    if let displayModel = displayModel as? SportDisplayModel {
                        switch displayModel.leagueId {
                        case Constants.Ids.nba:
                            dic = await nameProvider.getDictionary(Constants.Keys.nbaTeamDic)
                        case Constants.Ids.kbo:
                            dic = await nameProvider.getDictionary(Constants.Keys.kboTeamDic)
                        case Constants.Ids.mlb:
                            dic = await nameProvider.getDictionary(Constants.Keys.mlbTeamDic)
                        default: break
                        }
                    }
                    
                    await send(.initNameDictionary(dic))
                }
                
            case .initNameDictionary(let dic):
                state.teamNameDictionary = dic
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
