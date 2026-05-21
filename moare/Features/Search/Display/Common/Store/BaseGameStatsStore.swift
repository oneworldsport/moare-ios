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
        case initNameDictionary(_ player: [String: String], _ team: [String: String])
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
