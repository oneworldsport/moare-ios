//
//  BaseInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 5/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BaseInfoStore<T> {
    
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
        case initNameDictionary(_ player: [String: String], _ team: [String: String])
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData:
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
            }
        }
    }
}
