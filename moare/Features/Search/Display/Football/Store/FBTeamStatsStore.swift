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
                case let id where Constants.Ids.footballLeagues.contains(id):
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                default: break
                }
                
                state.team = displayModel.team
                state.venue = displayModel.venue
                
                // 리그 기록을 제일 첫번째 아이템으로
                state.statsList = displayModel.stats.sorted { a, b in
                    let aIsLeague = Constants.Ids.footballLeagues.contains(a.league.id)
                    let bIsLeague = Constants.Ids.footballLeagues.contains(b.league.id)
                    
                    if aIsLeague && !bIsLeague {
                        return true
                    } else if !aIsLeague && bIsLeague {
                        return false
                    } else {
                        return false
                    }
                }

                return .none
            }
        }
    }
}
