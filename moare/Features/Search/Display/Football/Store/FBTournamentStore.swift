//
//  FBTournamentStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/15/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTournamentStore {
    typealias BaseTournament = BaseTournamentStore<FBTournamentDisplayModel>
    
    @ObservableState
    struct State {
        var baseTournament = BaseTournament.State()
        
        var gameListDic: [String: [[FBGameForSchedule]]] = [:]
    }
    
    enum Action {
        case baseTournament(BaseTournament.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseTournament, action: \.baseTournament) {
            BaseTournament()
        }
        
        Reduce { state, action in
            switch action {
            case .baseTournament(.initData):
                let tournamentTeams = state.baseTournament.tournamentTeams
                let displayModel = state.baseTournament.displayModel
                let leagueId = displayModel?.leagueId ?? Constants.Ids.faCup
                let season = displayModel?.season ?? CalendarUtil.currentYear
                
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_32"] ?? []
                
                if let displayModel {
                    let firstRoundFilteredGames = displayModel.games.filter { game in
                        firstRoundTeamIds.contains(game.homeTeamId) && firstRoundTeamIds.contains(game.awayTeamId)
                    }
                    let firstRoundGrouped = Dictionary(grouping: firstRoundFilteredGames) { game in
                        let pair = [game.homeTeamId, game.awayTeamId].sorted()
                        return "\(pair[0])_\(pair[1])"
                    }
                    let firstRound = Array(firstRoundGrouped.values)
                    
                    state.gameListDic = [
                        "32강": firstRound
                    ]
                }
                
                return .none
                
            case .baseTournament(_):
                return .none
            }
        }
    }
}
