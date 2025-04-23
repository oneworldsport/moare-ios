//
//  FBTeamInfoStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamInfoStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBTeamInfoDisplayModel? = nil
        var team: FBTeamInfo? = nil
        var venue: FBVenue? = nil
        var league: FBLeague? = nil
        var stats: FBTeamStats? = nil
        var lastGame: FBGame? = nil
        var nextGame: FBGame? = nil
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: FBTeamInfoDisplayModel)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                
                if let leagueId = displayModel.leagueId {
                    switch leagueId {
                    case Constants.Ids.epl:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplTeamDic)
                    case Constants.Ids.laliga:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaTeamDic)
                    case Constants.Ids.bundesliga:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                    case Constants.Ids.ligue1:
                        state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                    default: break
                    }
                }
                
                state.team = displayModel.team
                state.venue = displayModel.venue
                state.league = displayModel.stats?.league
                state.stats = displayModel.stats
                state.lastGame = displayModel.lastGame
                state.nextGame = displayModel.nextGame
                
                return .none
            }
        }
    }
}
