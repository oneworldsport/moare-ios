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
        
        var gameListTuple: [(title: String, gameList: [[KBOGameForSchedule]?])] = []
        
        init(displayModel: KBOTournamentDisplayModel) {
            self.baseTournament = BaseTournament.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseTournament(BaseTournament.Action)
        
        case selectSeries(gameList: [KBOGameForSchedule])
        
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
                
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let secondRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let thirdRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let fourthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                if firstRoundTeamIds.count == 2 &&
                    secondRoundTeamIds.count == 2 &&
                    thirdRoundTeamIds.count == 2 &&
                    fourthRoundTeamIds.count == 2 {
                    let firstRoundSet = Set(Array(firstRoundTeamIds.prefix(2)))
                    let secondRoundSet = Set(Array(secondRoundTeamIds.prefix(2)))
                    let thirdRoundSet = Set(Array(thirdRoundTeamIds.prefix(2)))
                    let fourthRoundSet = Set(Array(fourthRoundTeamIds.prefix(2)))
                    
                    var games = displayModel.games
                    
                    let firstRound: [[KBOGameForSchedule]] = [
                        games.filter { firstRoundSet.contains($0.homeTeamId) && firstRoundSet.contains($0.awayTeamId) }
                    ]
                    // filter된 게임은 추후 filter할때 필요없으므로 games에서 지운다. 그렇지 않으면 다음라운드에서 set에 nil이 있는경우에 중복으로 game이 filter됨.
                    games.removeAll { firstRoundSet.contains($0.homeTeamId) && firstRoundSet.contains($0.awayTeamId) }
                    
                    let secondRound: [[KBOGameForSchedule]] = [
                        // NOTE: set에 nil이 있다면(아직 상대가 안정해짐) game에 awayTeamId나 homeTeamId중 하나만 있어도 filter
                        games.filter {
                            (secondRoundSet.contains($0.homeTeamId) && secondRoundSet.contains($0.awayTeamId)) ||
                            (secondRoundSet.contains(nil) ? (secondRoundSet.contains($0.homeTeamId) || secondRoundSet.contains($0.awayTeamId)) : false)
                        }
                    ]
                    games.removeAll {
                        (secondRoundSet.contains($0.homeTeamId) && secondRoundSet.contains($0.awayTeamId)) ||
                        (secondRoundSet.contains(nil) ? (secondRoundSet.contains($0.homeTeamId) || secondRoundSet.contains($0.awayTeamId)) : false)
                    }
                    
                    let thirdRound: [[KBOGameForSchedule]] = [
                        games.filter {
                            (thirdRoundSet.contains($0.homeTeamId) && thirdRoundSet.contains($0.awayTeamId)) ||
                            (thirdRoundSet.contains(nil) ? (thirdRoundSet.contains($0.homeTeamId) || thirdRoundSet.contains($0.awayTeamId)) : false)
                        }
                    ]
                    games.removeAll {
                        (thirdRoundSet.contains($0.homeTeamId) && thirdRoundSet.contains($0.awayTeamId)) ||
                        (thirdRoundSet.contains(nil) ? (thirdRoundSet.contains($0.homeTeamId) || thirdRoundSet.contains($0.awayTeamId)) : false)
                    }
                    
                    let fourthRound: [[KBOGameForSchedule]] = [
                        games.filter {
                            (fourthRoundSet.contains($0.homeTeamId) && fourthRoundSet.contains($0.awayTeamId)) ||
                            (fourthRoundSet.contains(nil) ? (fourthRoundSet.contains($0.homeTeamId) || fourthRoundSet.contains($0.awayTeamId)) : false)
                        }
                    ]
                    games.removeAll {
                        (fourthRoundSet.contains($0.homeTeamId) && fourthRoundSet.contains($0.awayTeamId)) ||
                        (fourthRoundSet.contains(nil) ? (fourthRoundSet.contains($0.homeTeamId) || fourthRoundSet.contains($0.awayTeamId)) : false)
                    }
                        
                    state.gameListTuple = [
                        ("와일드카드 결정전", firstRound),
                        ("준플레이오프", secondRound),
                        ("플레이오프", thirdRound),
                        ("한국시리즈", fourthRound)
                    ]
                }
                
                return .none
                
            case let .selectSeries(gameList):
                let responseModel = KBOGameScheduleResponseModel(
                    scheduleType: .teamFlat,
                    scheduledMonths: nil,
                    schedule: gameList
                )
                
                let dataModel: SportDecodableModel = .kboLeagueSchedule(
                    responseModel,
                    ModelConverter.shared.kboLeagueScheduleConverter(response: responseModel)
                )
                
                return .send(.delegate(.showLeagueSchedule(model: dataModel)))
                
            case .baseTournament(_):
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
