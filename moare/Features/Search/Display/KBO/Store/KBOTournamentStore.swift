//
//  KBOTournamentStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/17/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOTournamentStore {
    typealias BaseTournament = BaseTournamentStore<KBOTournamentDisplayModel>
    
    @ObservableState
    struct State {
        var baseTournament: BaseTournament.State
        
        var gameListDic: [String: [[KBOGameForSchedule]]] = [:]
        
        init(displayModel: KBOTournamentDisplayModel) {
            self.baseTournament = BaseTournament.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseTournament(BaseTournament.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseTournament, action: \.baseTournament) { BaseTournament() }
        
        Reduce { state, action in
            switch action {
            case .baseTournament(.initData):
                let tournamentTeams = state.baseTournament.tournamentTeams
                let displayModel = state.baseTournament.displayModel
                let leagueId = displayModel.leagueId
                let season = displayModel.season
                
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                
                let firstRoundFilteredGames = displayModel.games.filter { game in
                    firstRoundTeamIds.contains(game.homeTeamId) && firstRoundTeamIds.contains(game.awayTeamId)
                }
                let firstRoundGrouped = Dictionary(grouping: firstRoundFilteredGames) { game in
                    let pair = [game.homeTeamId, game.awayTeamId].sorted()
                    return "\(pair[0])_\(pair[1])"
                }
                let firstRound = Array(firstRoundGrouped.values)
                
                state.gameListDic = [
                    "와일드카드 결정전": firstRound,
//                        "준플레이오프": firstRound,
//                        "플레이오프": firstRound,
//                        "한국시리즈": firstRound
                ]
                
                return .none
            case .baseTournament(_):
                return .none
            }
        }
    }
}
