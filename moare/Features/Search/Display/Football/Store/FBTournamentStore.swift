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
        
        case selectSeries(gameList: [FBGameForSchedule])
        case selectGame(game: FBGameForSchedule)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showLeagueSchedule(model: SportDecodableModel)
        case showGameStats(model: SportDecodableModel)
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
                
                if leagueId == Constants.Ids.mls {
                    let firstRoundTeams = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                    let westFirstRoundTeams = Array(firstRoundTeams.prefix(8))
                    let eastFirstRoundTeams = Array(firstRoundTeams.suffix(8))
                    
                    let secondRoundTeams = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                    let westSecondRoundTeams = Array(secondRoundTeams.prefix(4))
                    let eastSecondRoundTeams = Array(secondRoundTeams.suffix(4))
                    
                    let thirdRoundTeams = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                    let westThirdRoundTeams = Array(thirdRoundTeams.prefix(2))
                    let eastThirdRoundTeams = Array(thirdRoundTeams.suffix(2))
                    
                    let fourthRoundTeams = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                    
                    let westFirstRoundPairedTeams = westFirstRoundTeams.chunked(by: 2)
                    let eastFirstRoundPairedTeams = eastFirstRoundTeams.chunked(by: 2)
                    let westSecondRoundPairedTeams = westSecondRoundTeams.chunked(by: 2)
                    let eastSecondRoundPairedTeams = eastSecondRoundTeams.chunked(by: 2)
                    let westThirdRoundPairedTeams = westThirdRoundTeams.chunked(by: 2)
                    let eastThirdRoundPairedTeams = eastThirdRoundTeams.chunked(by: 2)
                    let fourthRoundPairedTeams = fourthRoundTeams.chunked(by: 2)
                    
                    var games = displayModel.games
                    
                    let (_, westFirstRound) =  Util.collectRound(from: westFirstRoundPairedTeams, games: &games)
                    let (_, eastFirstRound) =  Util.collectRound(from: eastFirstRoundPairedTeams, games: &games)
                    let (_, westSecondRound) =  Util.collectRound(from: westSecondRoundPairedTeams, games: &games)
                    let (_, eastSecondRound) =  Util.collectRound(from: eastSecondRoundPairedTeams, games: &games)
                    let (_, westThirdRound) =  Util.collectRound(from: westThirdRoundPairedTeams, games: &games)
                    let (_, eastThirdRound) =  Util.collectRound(from: eastThirdRoundPairedTeams, games: &games)
                    let (_, fourthRound) =  Util.collectRound(from: fourthRoundPairedTeams, games: &games)
                    
                    state.gameListTuple = [
                        ("서부 컨퍼런스 1라운드", westFirstRound),
                        ("서부 컨퍼런스 세미파이널", westSecondRound),
                        ("서부 컨퍼런스 파이널", westThirdRound),
                        ("MLS 컵", fourthRound),
                        ("동부 컨퍼런스 파이널", eastThirdRound),
                        ("동부 컨퍼런스 세미파이널", eastSecondRound),
                        ("동부 컨퍼런스 1라운드", eastFirstRound)
                    ]
                } else {
                    let firstRoundTeams = tournamentTeams["\(leagueId)_\(season)_64"] ?? []
                    let secondRoundTeams = tournamentTeams["\(leagueId)_\(season)_32"] ?? []
                    let thirdRoundTeams = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                    let fourthRoundTeams = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                    let fifthRoundTeams = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                    let sixthRoundTeams = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                    
                    let firstRoundPairedTeams = firstRoundTeams.chunked(by: 2)
                    let secondRoundPairedTeams = secondRoundTeams.chunked(by: 2)
                    let thirdRoundPairedTeams = thirdRoundTeams.chunked(by: 2)
                    let fourthRoundPairedTeams = fourthRoundTeams.chunked(by: 2)
                    let fifthRoundPairedTeams = fifthRoundTeams.chunked(by: 2)
                    let sixthRoundPairedTeams = sixthRoundTeams.chunked(by: 2)
                    
                    var games = displayModel.games
                    
                    let (_, firstRound) =  Util.collectRound(from: firstRoundPairedTeams, games: &games)
                    let (_, secondRound) =  Util.collectRound(from: secondRoundPairedTeams, games: &games)
                    let (_, thirdRound) =  Util.collectRound(from: thirdRoundPairedTeams, games: &games)
                    let (_, fourthRound) =  Util.collectRound(from: fourthRoundPairedTeams, games: &games)
                    let (_, fifthRound) =  Util.collectRound(from: fifthRoundPairedTeams, games: &games)
                    let (_, sixthRound) =  Util.collectRound(from: sixthRoundPairedTeams, games: &games)
                    
                    let rounds: [(title: String, gameList: [[FBGameForSchedule]?])] = [
                        ("64강", firstRound),
                        ("32강", secondRound),
                        ("16강", thirdRound),
                        ("8강", fourthRound),
                        ("준결승", fifthRound),
                        ("결승", sixthRound)
                    ]
                    
                    // 가장 먼저 비어있지 않은 라운드부터 마지막 라운드까지 할당.
                    // ex: firstRound가 비어있고 secondRound에 값이 있으면 그 이후는 비어있는거와 상관없이 모두 할당해서, secondRound ~ fifthRound 값이 들어감.
                    if let startIndex = rounds.firstIndex(where: { !$0.gameList.isEmpty }) {
                        state.gameListTuple = Array(rounds[startIndex...])
                    }
                }
                
                return .none
                
            case let .selectSeries(gameList):
                let responseModel = FBGameScheduleResponseModel(
                    scheduleType: .teamFlat,
                    scheduledMonths: nil,
                    startDate: nil,
                    endDate: nil,
                    relatedLeagueIds: nil,
                    schedule: gameList,
                    tournamentStartDate: nil
                )
                
                let dataModel: SportDecodableModel = .fbLeagueSchedule(
                    responseModel,
                    ModelConverter.shared.fbLeagueScheduleConverter(response: responseModel)
                )
                
                return .send(.delegate(.showLeagueSchedule(model: dataModel)))
                
            case let .selectGame(game):
                return .run { [displayModel = state.baseTournament.displayModel] send in
                    let result = try await SearchClient().fetchById(
                        season: displayModel.season,
                        category: "football",
                        date: game.date,
                        dataType: "football_game_stats",
                        leagueId: displayModel.leagueId,
                        id: game.gameId
                    )
                    
                    await send(.delegate(.showGameStats(model: result.data)))
                }
                
            case .baseTournament:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}
