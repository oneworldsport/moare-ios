//
//  FBTeamStatsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamStatsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBTeamStatsDisplayModel? = nil
        var statsList: [FBTeamStats] = []
        var team: FBTeamInfo? = nil
        var venue: FBVenue? = nil
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: FBTeamStatsDisplayModel)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                
                switch displayModel.leagueId {
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
                
                state.statsList = displayModel.stats
                state.team = displayModel.team
                state.venue = displayModel.venue

                return .none
            }
        }
    }
}
