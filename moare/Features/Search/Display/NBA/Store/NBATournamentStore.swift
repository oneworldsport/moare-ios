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
                let season = displayModel.season
                
                // 시드 순서를 유지해야해서 다음과 같은 로직 적용
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
                
                let (westFirstRoundSeedTuple, westFirstRound) =  Util.collectRound(from: westFirstRoundPairedTeams, games: &games)
                let (eastFirstRoundSeedTuple, eastFirstRound) =  Util.collectRound(from: eastFirstRoundPairedTeams, games: &games)
                let (westSecondRoundSeedTuple, westSecondRound) =  Util.collectRound(from: westSecondRoundPairedTeams, games: &games)
                let (eastSecondRoundSeedTuple, eastSecondRound) =  Util.collectRound(from: eastSecondRoundPairedTeams, games: &games)
                let (westThirdRoundSeedTuple, westThirdRound) =  Util.collectRound(from: westThirdRoundPairedTeams, games: &games)
                let (eastThirdRoundSeedTuple, eastThirdRound) =  Util.collectRound(from: eastThirdRoundPairedTeams, games: &games)
                let (fourthRoundSeedTuple, fourthRound) =  Util.collectRound(from: fourthRoundPairedTeams, games: &games)
                
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
                    startDate: nil,
                    endDate: nil,
                    relatedLeagueIds: nil,
                    schedule: gameList,
                    tournamentStartDate: nil
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
