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
        
        var gameListTuple: [(title: String, gameList: [[NBAGameForSchedule]?])] = []
        var seedIdTupleList: [[(topSeedId: Int?, lowerSeedId: Int?)]] = []
        
        init(displayModel: NBATournamentDisplayModel) {
            self.baseTournament = BaseTournament.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseTournament(BaseTournament.Action)
        
        case selectSeries(gameList: [NBAGameForSchedule])
        
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
                //            let topSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, teamId: games.first!.homeTeamId) : nil
                //            let lowerSeedTeamId = games.first != nil ? Constants.Ids.checkTeamId(leagueId: leagueId, teamId: games.first!.awayTeamId) : nil
                let tournamentTeams = state.baseTournament.tournamentTeams
                let displayModel = state.baseTournament.displayModel
                let leagueId = displayModel.leagueId
//                let season = displayModel.season
                let season = 2024
                
                // 시드 순서를 유지해야해서 다음과 같은 로직 적용
                let firstRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let westFirstRoundTeamIds = Array(firstRoundTeamIds.prefix(8))
                let eastFirstRoundTeamIds = Array(firstRoundTeamIds.suffix(8))
                
                let secondRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let westSecondRoundTeamIds = Array(secondRoundTeamIds.prefix(4))
                let eastSecondRoundTeamIds = Array(secondRoundTeamIds.suffix(4))
                
                let thirdRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let westThirdRoundTeamIds = Array(thirdRoundTeamIds.prefix(2))
                let eastThirdRoundTeamIds = Array(thirdRoundTeamIds.suffix(2))
                
                let fourthRoundTeamIds = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                let westFirstRoundPairedTeamIds = westFirstRoundTeamIds.chunked(by: 2)
                let eastFirstRoundPairedTeamIds = eastFirstRoundTeamIds.chunked(by: 2)
                let westSecondRoundPairedTeamIds = westSecondRoundTeamIds.chunked(by: 2)
                let eastSecondRoundPairedTeamIds = eastSecondRoundTeamIds.chunked(by: 2)
                let westThirdRoundPairedTeamIds = westThirdRoundTeamIds.chunked(by: 2)
                let eastThirdRoundPairedTeamIds = eastThirdRoundTeamIds.chunked(by: 2)
                let fourthRoundPairedTeamIds = fourthRoundTeamIds.chunked(by: 2)
                
                var games = displayModel.games
                
                let (westFirstRoundSeedTuple, westFirstRound) =  Util.collectRound(from: westFirstRoundPairedTeamIds, games: &games)
                let (eastFirstRoundSeedTuple, eastFirstRound) =  Util.collectRound(from: eastFirstRoundPairedTeamIds, games: &games)
                let (westSecondRoundSeedTuple, westSecondRound) =  Util.collectRound(from: westSecondRoundPairedTeamIds, games: &games)
                let (eastSecondRoundSeedTuple, eastSecondRound) =  Util.collectRound(from: eastSecondRoundPairedTeamIds, games: &games)
                let (westThirdRoundSeedTuple, westThirdRound) =  Util.collectRound(from: westThirdRoundPairedTeamIds, games: &games)
                let (eastThirdRoundSeedTuple, eastThirdRound) =  Util.collectRound(from: eastThirdRoundPairedTeamIds, games: &games)
                let (fourthRoundSeedTuple, fourthRound) =  Util.collectRound(from: fourthRoundPairedTeamIds, games: &games)
                
                state.gameListTuple = [
                    ("서부 컨퍼런스 1라운드", westFirstRound),
                    ("서부 컨퍼런스 세미파이널", westSecondRound),
                    ("서부 컨퍼런스 파이널", westThirdRound),
                    ("NBA 파이널", fourthRound),
                    ("동부 컨퍼런스 파이널", eastThirdRound),
                    ("동부 컨퍼런스 세미파이널", eastSecondRound),
                    ("동부 컨퍼런스 1라운드", eastFirstRound)
                ]
                
                // gameListTuple에 추가되는 순서대로 추가
                state.seedIdTupleList.append(westFirstRoundSeedTuple)
                state.seedIdTupleList.append(westSecondRoundSeedTuple)
                state.seedIdTupleList.append(westThirdRoundSeedTuple)
                state.seedIdTupleList.append(fourthRoundSeedTuple)
                state.seedIdTupleList.append(eastThirdRoundSeedTuple)
                state.seedIdTupleList.append(eastSecondRoundSeedTuple)
                state.seedIdTupleList.append(eastFirstRoundSeedTuple)
                
                return .none
                
            case let .selectSeries(gameList):
                let responseModel = NBAGameScheduleResponseModel(
                    scheduleType: .teamFlat,
                    scheduledMonths: nil,
                    schedule: gameList
                )
                
                let dataModel: SportDecodableModel = .nbaLeagueSchedule(
                    responseModel,
                    ModelConverter.shared.nbaLeagueScheduleConverter(response: responseModel)
                )
                
                return .send(.delegate(.showLeagueSchedule(model: dataModel)))
                
            case .baseTournament:
                return .none
                
            case .delegate:
                return .none
            } // switch action
        }
    }
}
