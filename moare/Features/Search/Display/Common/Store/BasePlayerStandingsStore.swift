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
        var displayModel: T? = nil
        var displayDataState: ApiFetchState = .idle
        
        /* ---------------------
           ui state
           --------------------- */
        var firstSelectedIndex = 0
        var secondSelectedIndex = 0
        var shouldScrollCategory = false
        var entityIndex: Int? = nil
        var filteredStandingsStartIndex = 0
        
        /* ---------------------
           etc
           --------------------- */
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
        var selectedEntity: EntityInfo? = nil
        var filteredStandingsEndIndex = 0
    }
    
    enum Action {
        case initData(displayModel: T)
        case selectFirstCategory(index: Int)
        case selectSecondCategory(index: Int, category: String)
//        case fetchStandings(category: String)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.displayDataState = .idle
                
                state.firstSelectedIndex = 0
                state.secondSelectedIndex = 0
                state.shouldScrollCategory = false
                state.entityIndex = nil
                state.filteredStandingsStartIndex = 0
                
                state.selectedEntity = nil
                state.filteredStandingsEndIndex = 0
                
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
                    
                    let keywords = displayModel.keywords
                    if !keywords.isEmpty {
                        // Check matching keyword in the order of categories, doesn't matter what keyword is in keywords
                        let index = StringConstants.Football.playerStandingsSecondCategories.firstIndex { category in
                            let keyword = keywords.first { $0.keyword == category }
                            return keyword != nil
                        }
                        
                        if let index {
                            state.secondSelectedIndex = index
                        }
                    }
                }
                
                return .none
                
            case .selectFirstCategory(let index):
                state.shouldScrollCategory = true
                
                return .none
                
            case .selectSecondCategory(let index, let category):
                state.shouldScrollCategory = false
                state.secondSelectedIndex = index
                
                return .none
                
//            case .fetchStandings(let category):
//                return .none
            }
        }
    }
}
