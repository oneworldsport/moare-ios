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
        var seedIdTupleList: [[(topSeedId: Int?, lowerSeedId: Int?)]] = []
        
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
                
                let firstRoundTeams = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let secondRoundTeams = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let thirdRoundTeams = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let fourthRoundTeams = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                if firstRoundTeams.count == 2 &&
                    secondRoundTeams.count == 2 &&
                    thirdRoundTeams.count == 2 &&
                    fourthRoundTeams.count == 2 {
                    
                    var games = displayModel.games.filter { $0.gameStatus != Constants.GameStatus.KBO.canceled }
                    
                    let (firstRoundSeedTuple, firstRound) = Util.collectRound(from: [firstRoundTeams], games: &games)
                    let (secondRoundSeedTuple, secondRound) = Util.collectRound(from: [secondRoundTeams], games: &games)
                    let (thirdRoundSeedTuple, thirdRound) = Util.collectRound(from: [thirdRoundTeams], games: &games)
                    let (fourthRoundSeedTuple, fourthRound) = Util.collectRound(from: [fourthRoundTeams], games: &games)
                    
                    state.gameListTuple = [
                        ("와일드카드 결정전", firstRound),
                        ("준플레이오프", secondRound),
                        ("플레이오프", thirdRound),
                        ("한국시리즈", fourthRound)
                    ]
                    
                    // gameListTuple에 추가되는 순서대로 추가
                    state.seedIdTupleList.append(firstRoundSeedTuple)
                    state.seedIdTupleList.append(secondRoundSeedTuple)
                    state.seedIdTupleList.append(thirdRoundSeedTuple)
                    state.seedIdTupleList.append(fourthRoundSeedTuple)
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
