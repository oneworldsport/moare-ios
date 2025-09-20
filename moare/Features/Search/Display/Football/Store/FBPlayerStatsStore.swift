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
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                case Constants.Ids.laliga:
                    state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaPlayerDic)
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                case Constants.Ids.bundesliga:
                    state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaPlayerDic)
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                case Constants.Ids.ligue1:
                    state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaPlayerDic)
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                case Constants.Ids.seriea:
                    state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.serieaPlayerDic)
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                case Constants.Ids.mls:
                    state.playerNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlsPlayerDic)
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.footballTeamDic)
                default: break
                }
                
                state.player = displayModel.player
                state.team = displayModel.team
                state.nationalityKrName = EnNameTranslationUtility.translateByDic(type: .country, input: displayModel.player.nationality)
                
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
