//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBATournamentStore {
    typealias BaseTournament = BaseTournamentStore<NBATournamentDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let infoContainerWidth: CGFloat = 130
        let hBarWidth: CGFloat = 30
        let barThickness: CGFloat = 1
        
        /* ---------------------
           data state
           --------------------- */
        var baseTournament: BaseTournament.State
        
        var gameListTuple: [(title: String, gameList: [[NBAGameForSchedule]])] = []
        
        init(displayModel: NBATournamentDisplayModel) {
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
//                let season = displayModel.season
                let season = 2024
                
                // 시드 순서를 유지해야해서 다음과 같은 로직 적용
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let westFristRoundTeamIds = Array(firstRoundTeamIds.prefix(8))
                let eastFirstRoundTeamIds = Array(firstRoundTeamIds.suffix(8))
                
                let secondRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let westSecondRoundTeamIds = Array(secondRoundTeamIds.prefix(4))
                let eastSecondRoundTeamIds = Array(secondRoundTeamIds.suffix(4))
                
                let thirdRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let westThirdRoundTeamIds = Array(thirdRoundTeamIds.prefix(2))
                let eastThirdRoundTeamIds = Array(thirdRoundTeamIds.suffix(2))
                
                let fourthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                let westFirstRoundPairedTeamIds = stride(from: 0, to: westFristRoundTeamIds.count, by: 2).map {
                    Array(westFristRoundTeamIds[$0 ..< min($0 + 2, westFristRoundTeamIds.count)])
                }
                let eastFirstRoundPairedTeamIds = stride(from: 0, to: eastFirstRoundTeamIds.count, by: 2).map {
                    Array(eastFirstRoundTeamIds[$0 ..< min($0 + 2, eastFirstRoundTeamIds.count)])
                }
                
                let westSecondRoundPairedTeamIds = stride(from: 0, to: westSecondRoundTeamIds.count, by: 2).map {
                    Array(westSecondRoundTeamIds[$0 ..< min($0 + 2, westSecondRoundTeamIds.count)])
                }
                let eastSecondRoundPairedTeamIds = stride(from: 0, to: eastSecondRoundTeamIds.count, by: 2).map {
                    Array(eastSecondRoundTeamIds[$0 ..< min($0 + 2, eastSecondRoundTeamIds.count)])
                }
                
                let westThirdRoundPairedTeamIds = stride(from: 0, to: westThirdRoundTeamIds.count, by: 2).map {
                    Array(westThirdRoundTeamIds[$0 ..< min($0 + 2, westThirdRoundTeamIds.count)])
                }
                let eastThirdRoundPairedTeamIds = stride(from: 0, to: eastThirdRoundTeamIds.count, by: 2).map {
                    Array(eastThirdRoundTeamIds[$0 ..< min($0 + 2, eastThirdRoundTeamIds.count)])
                }
                
                let fourthRoundPairedTeamIds = stride(from: 0, to: fourthRoundTeamIds.count, by: 2).map {
                    Array(fourthRoundTeamIds[$0 ..< min($0 + 2, fourthRoundTeamIds.count)])
                }
                
                let games = displayModel.games
                
                let westFirstRound: [[NBAGameForSchedule]] = westFirstRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                let eastFirstRound: [[NBAGameForSchedule]] = eastFirstRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                
                let westSecondRound: [[NBAGameForSchedule]] = westSecondRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                let eastSecondRound: [[NBAGameForSchedule]] = eastSecondRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                
                let westThirdRound: [[NBAGameForSchedule]] = westThirdRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                let eastThirdRound: [[NBAGameForSchedule]] = eastThirdRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                
                let fourthRound: [[NBAGameForSchedule]] = fourthRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                
                state.gameListTuple = [
                    ("서부 컨퍼런스 1라운드", westFirstRound),
                    ("서부 컨퍼런스 세미파이널", westSecondRound),
                    ("서부 컨퍼런스 파이널", westThirdRound),
                    ("NBA 파이널", fourthRound),
                    ("동부 컨퍼런스 파이널", eastThirdRound),
                    ("동부 컨퍼런스 세미파이널", eastSecondRound),
                    ("동부 컨퍼런스 1라운드", eastFirstRound)
                ]
                
                return .none
                
            case .baseTournament:
                return .none
            } // switch action
            
            func getGameSeries(gameList: [NBAGame]?) -> NBAGame? {
                return gameList?.max(by: {
                    (($0.seasonSeries?.homeTeamWins ?? 0) + ($0.seasonSeries?.homeTeamLosses ?? 0)) < (($1.seasonSeries?.homeTeamWins ?? 0) + ($1.seasonSeries?.homeTeamLosses ?? 0))
                })
            }
        }
    }
}
