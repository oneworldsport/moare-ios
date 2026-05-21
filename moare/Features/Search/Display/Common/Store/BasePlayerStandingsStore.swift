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
        case initNameDictionary(_ player: [String: String], _ team: [String: String])
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
                    case Constants.Ids.nba:
                        playerStandingsSecondCategories = StringConstants.NBA.playerStandingsSecondCategories
                    case Constants.Ids.kbo:
                        playerStandingsSecondCategories = StringConstants.KBO.playerStandingsSecondCategories
                    case Constants.Ids.mlb:
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
                
                return .run { [displayModel = state.displayModel] send in
                    var playerDic = await nameProvider.getDictionary(Constants.Keys.footballTeamDic)
                    var teamDic = await nameProvider.getDictionary(Constants.Keys.footballTeamDic)
                    
                    if let displayModel = displayModel as? SportDisplayModel {
                        switch displayModel.leagueId {
                        case Constants.Ids.nba:
                            playerDic = await nameProvider.getDictionary(Constants.Keys.nbaPlayerDic)
                            teamDic = await nameProvider.getDictionary(Constants.Keys.nbaTeamDic)
                        case Constants.Ids.kbo:
                            teamDic = await nameProvider.getDictionary(Constants.Keys.kboTeamDic)
                        case Constants.Ids.mlb:
                            playerDic = await nameProvider.getDictionary(Constants.Keys.mlbPlayerDic)
                            teamDic = await nameProvider.getDictionary(Constants.Keys.mlbTeamDic)
                        default: break
                        }
                    }
                    
                    await send(.initNameDictionary(playerDic, teamDic))
                }
                
            case let .initNameDictionary(playerDic, teamDic):
                state.playerNameDictionary = playerDic
                state.teamNameDictionary = teamDic
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
