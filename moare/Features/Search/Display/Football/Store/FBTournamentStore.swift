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
                let secondRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let thirdRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let fourthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let fifthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                let firstRoundPairedTeamIds = stride(from: 0, to: firstRoundTeamIds.count, by: 2).map {
                    Array(firstRoundTeamIds[$0 ..< min($0 + 2, firstRoundTeamIds.count)])
                }
                let secondRoundPairedTeamIds = stride(from: 0, to: secondRoundTeamIds.count, by: 2).map {
                    Array(secondRoundTeamIds[$0 ..< min($0 + 2, secondRoundTeamIds.count)])
                }
                let thirdRoundPairedTeamIds = stride(from: 0, to: thirdRoundTeamIds.count, by: 2).map {
                    Array(thirdRoundTeamIds[$0 ..< min($0 + 2, thirdRoundTeamIds.count)])
                }
                let fourthRoundPairedTeamIds = stride(from: 0, to: fourthRoundTeamIds.count, by: 2).map {
                    Array(fourthRoundTeamIds[$0 ..< min($0 + 2, fourthRoundTeamIds.count)])
                }
                let fifthRoundPairedTeamIds = stride(from: 0, to: fifthRoundTeamIds.count, by: 2).map {
                    Array(fifthRoundTeamIds[$0 ..< min($0 + 2, fifthRoundTeamIds.count)])
                }
                
                let games = displayModel.games
                
                let firstRound: [[FBGameForSchedule]] = firstRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                let secondRound: [[FBGameForSchedule]] = secondRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                let thirdRound: [[FBGameForSchedule]] = thirdRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                let fourthRound: [[FBGameForSchedule]] = fourthRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                let fifthRound: [[FBGameForSchedule]] = fifthRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                
                let rounds: [(title: String, gameList: [[FBGameForSchedule]])] = [
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
