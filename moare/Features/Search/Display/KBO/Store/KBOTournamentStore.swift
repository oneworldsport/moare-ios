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
                
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let secondRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let thirdRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let fourthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                if firstRoundTeamIds.count == 2 &&
                    secondRoundTeamIds.count == 2 &&
                    thirdRoundTeamIds.count == 2 &&
                    fourthRoundTeamIds.count == 2 {
                    
                    var games = displayModel.games
                    
                    var (firstRoundSeedTuple, firstRound) = Util.collectRound(from: [firstRoundTeamIds], games: &games)
                    var (secondRoundSeedTuple, secondRound) = Util.collectRound(from: [secondRoundTeamIds], games: &games)
                    var (thirdRoundSeedTuple, thirdRound) = Util.collectRound(from: [thirdRoundTeamIds], games: &games)
                    var (fourthRoundSeedTuple, fourthRound) = Util.collectRound(from: [fourthRoundTeamIds], games: &games)
                    
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
