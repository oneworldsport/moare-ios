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
        
        var gameListTuple: [(title: String, gameList: [[FBGameForSchedule]?])] = []
        
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
                
                let firstRoundTeams = tournamentTeams["\(leagueId)_\(season)_32"] ?? []
                let secondRoundTeams = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let thirdRoundTeams = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let fourthRoundTeams = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let fifthRoundTeams = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                let firstRoundPairedTeams = firstRoundTeams.chunked(by: 2)
                let secondRoundPairedTeams = secondRoundTeams.chunked(by: 2)
                let thirdRoundPairedTeams = thirdRoundTeams.chunked(by: 2)
                let fourthRoundPairedTeams = fourthRoundTeams.chunked(by: 2)
                let fifthRoundPairedTeams = fifthRoundTeams.chunked(by: 2)
                
                var games = displayModel.games
                
                let (_, firstRound) =  Util.collectRound(from: firstRoundPairedTeams, games: &games)
                let (_, secondRound) =  Util.collectRound(from: secondRoundPairedTeams, games: &games)
                let (_, thirdRound) =  Util.collectRound(from: thirdRoundPairedTeams, games: &games)
                let (_, fourthRound) =  Util.collectRound(from: fourthRoundPairedTeams, games: &games)
                let (_, fifthRound) =  Util.collectRound(from: fifthRoundPairedTeams, games: &games)
                
                let rounds: [(title: String, gameList: [[FBGameForSchedule]?])] = [
                    ("32강", firstRound),
                    ("16강", secondRound),
                    ("8강", thirdRound),
                    ("준결승", fourthRound),
                    ("결승", fifthRound)
                ]
                
                // 가장 먼저 비어있지 않은 라운드부터 마지막 라운드까지 할당.
                // ex: firstRound가 비어있고 secondRound에 값이 있으면 그 이후는 비어있는거와 상관없이 모두 할당해서, secondRound ~ fifthRound 값이 들어감.
                if let startIndex = rounds.firstIndex(where: { !$0.gameList.isEmpty }) {
                    state.gameListTuple = Array(rounds[startIndex...])
                }
                
                return .none
                
            case .baseTournament:
                return .none
            }
        }
    }
}
