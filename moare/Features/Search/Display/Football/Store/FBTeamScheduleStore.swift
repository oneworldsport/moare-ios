//
//  FBTeamScheduleStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/15/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamScheduleStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let itemHeight: CGFloat = 100
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBTeamScheduleDisplayModel? = nil
        var games: [FBGame] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var isAllResultOpened = false
        var gameResultOpenedStateList: [Int: Bool] = [:]
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: FBTeamScheduleDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        case toggleAllResult
        case updateResultOpenedState(fixtureId: Int, isOpened: Bool)
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.isAllResultOpened = false
                
                // init data
                state.displayModel = displayModel
                state.games = displayModel.games
                
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
                
                let gameResultOpenedStateList = (state.games).reduce(into: [:]) { $0[$1.fixture.id] = false }
                state.gameResultOpenedStateList = gameResultOpenedStateList
                
                return .none
                
            case .toggleAllResult:
                let newState = !state.isAllResultOpened
                state.isAllResultOpened = newState
                state.gameResultOpenedStateList = state.gameResultOpenedStateList.mapValues { _ in newState }
                
                return .none
                
            case .updateResultOpenedState(let fixtureId, let isOpened):
                state.gameResultOpenedStateList[fixtureId] = isOpened
                
                return .none
            } // switch action
        }
    }
}
