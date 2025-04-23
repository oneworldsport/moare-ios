//
//  FBPlayerInfoStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerInfoStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 30
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBPlayerInfoDisplayModel? = nil
        var player: FBPlayerInfo? = nil
        var stats: FBPlayerStats? = nil
        var team: FBTeamInfo? = nil
        var league: FBLeague? = nil
        var lastGame: FBGame? = nil
        var lastGamePlayerStats: FBGamePlayerStatsDetail? = nil
        var nextGame: FBGame? = nil
        var nationalityKrName = ""
        
        /* ---------------------
           etc
           --------------------- */
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: FBPlayerInfoDisplayModel)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                state.player = displayModel.info
                
                if let leagueId = displayModel.leagueId {
                    switch leagueId {
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
                }
                
                state.stats = displayModel.stats
                state.team = state.stats?.team
                state.league = state.stats?.league
                state.lastGame = displayModel.lastGame
                state.lastGamePlayerStats = displayModel.lastGamePlayerStats
                state.nextGame = displayModel.nextGame
                state.nationalityKrName = EnNameTranslationUtility.translateByDic(type: .country, input: displayModel.info.nationality)
                
                return .none
            }
        }
    }
}
