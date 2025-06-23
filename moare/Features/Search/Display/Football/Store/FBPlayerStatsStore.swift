//
//  FBPlayerStatsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation

import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerStatsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBPlayerStatsDisplayModel? = nil
        var statsList: [FBPlayerStats] = []
        var player: FBPlayerInfo? = nil
        var team: FBTeamInfo? = nil
        var nationalityKrName = ""
        
        /* ---------------------
           etc
           --------------------- */
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: FBPlayerStatsDisplayModel)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                
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
                    state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaPlayerDic)
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                default: break
                }
                
                state.statsList = displayModel.stats
                state.player = displayModel.player
                state.team = displayModel.team
                state.nationalityKrName = EnNameTranslationUtility.translateByDic(type: .country, input: displayModel.player.nationality)
                
                return .none
            }
        }
    }
}
