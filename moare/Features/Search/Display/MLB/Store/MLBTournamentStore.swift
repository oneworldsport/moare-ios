//
//  MLBTournamentStore.swift
//  moare
//
//  Created by Mohwa Yoon on 9/29/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBTournamentStore {
    typealias BaseTournament = BaseTournamentStore<MLBTournamentDisplayModel>
    
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
        
        var gameListTuple: [(title: String, gameList: [[MLBGameForSchedule]?])] = []
        
        init(displayModel: MLBTournamentDisplayModel) {
            self.baseTournament = BaseTournament.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseTournament(BaseTournament.Action)
        
        case selectSeries(gameList: [MLBGameForSchedule])
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showLeagueSchedule(model: SportDecodableModel)
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
                
                // 시드 순서를 유지해야해서 다음과 같은 로직 적용
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let nlFirstRoundTeamIds = Array(firstRoundTeamIds.prefix(4))
                let alFirstRoundTeamIds = Array(firstRoundTeamIds.suffix(4))
                
                let secondRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let nlSecondRoundTeamIds = Array(secondRoundTeamIds.prefix(4))
                let alSecondRoundTeamIds = Array(secondRoundTeamIds.suffix(4))
                
                let thirdRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let nlThirdRoundTeamIds = Array(thirdRoundTeamIds.prefix(2))
                let alThirdRoundTeamIds = Array(thirdRoundTeamIds.suffix(2))
                
                let fourthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                let nlFirstRoundPairedTeamIds = stride(from: 0, to: nlFirstRoundTeamIds.count, by: 2).map {
                    Array(nlFirstRoundTeamIds[$0 ..< min($0 + 2, nlFirstRoundTeamIds.count)])
                }
                let alFirstRoundPairedTeamIds = stride(from: 0, to: alFirstRoundTeamIds.count, by: 2).map {
                    Array(alFirstRoundTeamIds[$0 ..< min($0 + 2, alFirstRoundTeamIds.count)])
                }
                
                let nlSecondRoundPairedTeamIds = stride(from: 0, to: nlSecondRoundTeamIds.count, by: 2).map {
                    Array(nlSecondRoundTeamIds[$0 ..< min($0 + 2, nlSecondRoundTeamIds.count)])
                }
                let alSecondRoundPairedTeamIds = stride(from: 0, to: alSecondRoundTeamIds.count, by: 2).map {
                    Array(alSecondRoundTeamIds[$0 ..< min($0 + 2, alSecondRoundTeamIds.count)])
                }
                
                let nlThirdRoundPairedTeamIds = stride(from: 0, to: nlThirdRoundTeamIds.count, by: 2).map {
                    Array(nlThirdRoundTeamIds[$0 ..< min($0 + 2, nlThirdRoundTeamIds.count)])
                }
                let alThirdRoundPairedTeamIds = stride(from: 0, to: alThirdRoundTeamIds.count, by: 2).map {
                    Array(alThirdRoundTeamIds[$0 ..< min($0 + 2, alThirdRoundTeamIds.count)])
                }
                
                let fourthRoundPairedTeamIds = stride(from: 0, to: fourthRoundTeamIds.count, by: 2).map {
                    Array(fourthRoundTeamIds[$0 ..< min($0 + 2, fourthRoundTeamIds.count)])
                }
                
                //
                let games = displayModel.games
                
                var nlFirstRound: [[MLBGameForSchedule]?] = nlFirstRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                nlFirstRound.insert(nil, at: 1)
                var alFirstRound: [[MLBGameForSchedule]?] = alFirstRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter { set.contains($0.homeTeamId) && set.contains($0.awayTeamId) }
                }
                alFirstRound.insert(nil, at: 1)
                
                let nlSecondRound: [[MLBGameForSchedule]] = nlSecondRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter {
                        (set.contains($0.homeTeamId) && set.contains($0.awayTeamId)) ||
                        (set.contains($0.homeTeamId) && set.contains(nil)) ||
                        (set.contains(nil) && set.contains($0.awayTeamId))
                    }
                }
                let alSecondRound: [[MLBGameForSchedule]] = alSecondRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter {
                        (set.contains($0.homeTeamId) && set.contains($0.awayTeamId)) ||
                        (set.contains($0.homeTeamId) && set.contains(nil)) ||
                        (set.contains(nil) && set.contains($0.awayTeamId))
                    }
                }
                
                let nlThirdRound: [[MLBGameForSchedule]] = nlThirdRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter {
                        (set.contains($0.homeTeamId) && set.contains($0.awayTeamId)) ||
                        (set.contains($0.homeTeamId) && set.contains(nil)) ||
                        (set.contains(nil) && set.contains($0.awayTeamId))
                    }
                }
                let alThirdRound: [[MLBGameForSchedule]] = alThirdRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter {
                        (set.contains($0.homeTeamId) && set.contains($0.awayTeamId)) ||
                        (set.contains($0.homeTeamId) && set.contains(nil)) ||
                        (set.contains(nil) && set.contains($0.awayTeamId))
                    }
                }
                
                let fourthRound: [[MLBGameForSchedule]] = fourthRoundPairedTeamIds.map { pair in
                    let set = Set(pair.prefix(2))
                    return games.filter {
                        (set.contains($0.homeTeamId) && set.contains($0.awayTeamId)) ||
                        (set.contains($0.homeTeamId) && set.contains(nil)) ||
                        (set.contains(nil) && set.contains($0.awayTeamId))
                    }
                }
                
                state.gameListTuple = [
                    ("NL 와일드카드 시리즈", nlFirstRound),
                    ("NL 디비전 시리즈", nlSecondRound),
                    ("NL 챔피언십 시리즈", nlThirdRound),
                    ("월드 시리즈", fourthRound),
                    ("AL 챔피언십 시리즈", alThirdRound),
                    ("AL 디비전 시리즈", alSecondRound),
                    ("AL 와일드카드 시리즈", alFirstRound)
                ]
                
                return .none
                
            case let .selectSeries(gameList):
                let responseModel = MLBGameScheduleResponseModel(
                    scheduleType: .teamFlat,
                    scheduledMonths: nil,
                    schedule: gameList
                )
                
                let dataModel: SportDecodableModel = .mlbLeagueSchedule(
                    responseModel,
                    ModelConverter.shared.mlbLeagueScheduleConverter(response: responseModel)
                )
                
                return .send(.delegate(.showLeagueSchedule(model: dataModel)))
                
            case .baseTournament:
                return .none
                
            case .delegate:
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
