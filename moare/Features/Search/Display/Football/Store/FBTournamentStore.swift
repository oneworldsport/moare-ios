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
        var baseTournament: BaseTournament.State
        
        var gameListTuple: [(title: String, gameList: [[FBGameForSchedule]])] = []
        
        init(displayModel: FBTournamentDisplayModel) {
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
            case .baseTournament(.initTournamentTeams):
                let tournamentTeams = state.baseTournament.tournamentTeams
                let displayModel = state.baseTournament.displayModel
                let leagueId = displayModel.leagueId
                let season = displayModel.season
                
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_32"] ?? []
//                let secondRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
//                let thirdRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
//                let fourthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
//                let fifthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                let firstRoundPairedTeamIds = stride(from: 0, to: firstRoundTeamIds.count, by: 2).map {
                    Array(firstRoundTeamIds[$0 ..< min($0 + 2, firstRoundTeamIds.count)])
                }
                
                let games = displayModel.games
                
                let firstRound: [[FBGameForSchedule]] = firstRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                
                state.gameListTuple = [
                    ("32강", firstRound)
                ]
                
                return .none
                
            case .baseTournament:
                return .none
            }
        }
    }
}
