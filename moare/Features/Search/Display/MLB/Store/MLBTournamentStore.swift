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
        var seedIdTupleList: [[(topSeedId: Int?, lowerSeedId: Int?)]] = []
        
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
                let firstRoundTeams = tournamentTeams["\(leagueId)_\(season)_16"] ?? []
                let nlFirstRoundTeams = Array(firstRoundTeams.prefix(4))
                let alFirstRoundTeams = Array(firstRoundTeams.suffix(4))
                
                let secondRoundTeams = tournamentTeams["\(leagueId)_\(season)_8"] ?? []
                let nlSecondRoundTeams = Array(secondRoundTeams.prefix(4))
                let alSecondRoundTeams = Array(secondRoundTeams.suffix(4))
                
                let thirdRoundTeams = tournamentTeams["\(leagueId)_\(season)_4"] ?? []
                let nlThirdRoundTeams = Array(thirdRoundTeams.prefix(2))
                let alThirdRoundTeams = Array(thirdRoundTeams.suffix(2))
                
                let fourthRoundTeams = tournamentTeams["\(leagueId)_\(season)_2"] ?? []
                
                let nlFirstRoundPairedTeams = nlFirstRoundTeams.chunked(by: 2)
                let alFirstRoundPairedTeams = alFirstRoundTeams.chunked(by: 2)
                let nlSecondRoundPairedTeams = nlSecondRoundTeams.chunked(by: 2)
                let alSecondRoundPairedTeams = alSecondRoundTeams.chunked(by: 2)
                let nlThirdRoundPairedTeams = nlThirdRoundTeams.chunked(by: 2)
                let alThirdRoundPairedTeams = alThirdRoundTeams.chunked(by: 2)
                let fourthRoundPairedTeams = fourthRoundTeams.chunked(by: 2)
                
                var games = displayModel.games.filter { $0.gameStatus != Constants.GameStatus.MLB.postponed }
                
                var (nlFirstRoundSeedTuple, nlFirstRound) = Util.collectRound(from: nlFirstRoundPairedTeams, games: &games)
                var (alFirstRoundSeedTuple, alFirstRound) =  Util.collectRound(from: alFirstRoundPairedTeams, games: &games)
                // TournamentBracket화면에서 와일드카드 시리즈는 한시리즈를 비워놔야해서 추가
                nlFirstRound.insert(nil, at: 1)
                nlFirstRoundSeedTuple.insert((topSeedId: nil, lowerSeedId: nil), at: 1)
                alFirstRound.insert(nil, at: 1)
                alFirstRoundSeedTuple.insert((topSeedId: nil, lowerSeedId: nil), at: 1)
                
                let (nlSecondRoundSeedTuple, nlSecondRound) =  Util.collectRound(from: nlSecondRoundPairedTeams, games: &games)
                let (alSecondRoundSeedTuple, alSecondRound) =  Util.collectRound(from: alSecondRoundPairedTeams, games: &games)
                let (nlThirdRoundSeedTuple, nlThirdRound) =  Util.collectRound(from: nlThirdRoundPairedTeams, games: &games)
                let (alThirdRoundSeedTuple, alThirdRound) =  Util.collectRound(from: alThirdRoundPairedTeams, games: &games)
                let (fourthRoundSeedTuple, fourthRound) =  Util.collectRound(from: fourthRoundPairedTeams, games: &games)
                
                state.gameListTuple = [
                    ("NL 와일드카드 시리즈", nlFirstRound),
                    ("NL 디비전 시리즈", nlSecondRound),
                    ("NL 챔피언십 시리즈", nlThirdRound),
                    ("월드 시리즈", fourthRound),
                    ("AL 챔피언십 시리즈", alThirdRound),
                    ("AL 디비전 시리즈", alSecondRound),
                    ("AL 와일드카드 시리즈", alFirstRound)
                ]
                
                // gameListTuple에 추가되는 순서대로 추가
                state.seedIdTupleList.append(nlFirstRoundSeedTuple)
                state.seedIdTupleList.append(nlSecondRoundSeedTuple)
                state.seedIdTupleList.append(nlThirdRoundSeedTuple)
                state.seedIdTupleList.append(fourthRoundSeedTuple)
                state.seedIdTupleList.append(alThirdRoundSeedTuple)
                state.seedIdTupleList.append(alSecondRoundSeedTuple)
                state.seedIdTupleList.append(alFirstRoundSeedTuple)
                
                return .none
                
            case let .selectSeries(gameList):
                let responseModel = MLBGameScheduleResponseModel(
                    scheduleType: .teamFlat,
                    scheduledMonths: nil,
                    startDate: nil,
                    endDate: nil,
                    relatedLeagueIds: nil,
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
        }
    }
}
