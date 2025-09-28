//
//  BasePlayerStandingsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BasePlayerStandingsStore<T> {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: T
        var displayDataState: ApiFetchState = .idle
        
        /* ---------------------
           ui state
           --------------------- */
        var categorySelectedIndex = 0
        var shouldScrollCategory = false
        var entityIndex: Int? = nil
        var filteredStandingsStartIndex = 0
        var filteredStandingsEndIndex = 0
        
        /* ---------------------
           etc
           --------------------- */
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
        var selectedEntity: EntityInfo? = nil
        
        init(displayModel: T) {
            self.displayModel = displayModel
        }
    }
    
    enum Action {
        case initData
        case selectCategory(index: Int, category: String)
//        case fetchStandings(category: String)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
                // init with default value
                state.displayDataState = .idle
                
                state.categorySelectedIndex = 0
                state.shouldScrollCategory = false
                state.entityIndex = nil
                state.filteredStandingsStartIndex = 0
                state.filteredStandingsEndIndex = 0
                
                state.selectedEntity = nil
                
                var playerStandingsSecondCategories = StringConstants.Football.playerStandingsSecondCategories
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
                        playerStandingsSecondCategories = StringConstants.NBA.playerStandingsSecondCategories
                    case Constants.Ids.kbo:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.kboTeamDic)
                        playerStandingsSecondCategories = StringConstants.KBO.playerStandingsSecondCategories
                    case Constants.Ids.mlb:
                        state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbPlayerDic)
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlbTeamDic)
                        playerStandingsSecondCategories = StringConstants.MLB.playerStandingsSecondCategories
                    default: break
                    }
                    
                    let keywords = displayModel.keywords
                    if !keywords.isEmpty {
                        // Check matching keyword in the order of categories, doesn't matter what keyword is in keywords
                        let index = playerStandingsSecondCategories.firstIndex { category in
                            let keyword = keywords.first { $0.keyword == category }
                            return keyword != nil
                        }
                        
                        if let index {
                            state.categorySelectedIndex = index
                        }
                    }
                }
                
                return .none
                
            case let .selectCategory(index, category):
                state.shouldScrollCategory = false
                state.categorySelectedIndex = index
                
                return .none
                
//            case .fetchStandings(let category):
//                return .none
            }
        }
    }
}
