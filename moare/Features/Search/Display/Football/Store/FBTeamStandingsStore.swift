//
//  FBTeamStandingsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBTeamStandingsStore {
    typealias BaseStandings = BaseTeamStandingsStore<FBTeamStandingsDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let categoryItemHeight: CGFloat = 40
        let firstCategoryItemWidth: CGFloat = 132
        let intDataItemWidth: CGFloat = 50
        let stringDataItemWidth: CGFloat = 110
        let stringDataItemTextWidth: CGFloat = 34
        let categoryFontSize: CGFloat = 15
        let dataFontSize: CGFloat = 15
        let firstCategory = "팀순위"
        
        /* ---------------------
           data state
           --------------------- */
        let responseModel: FBTeamStandingsResponseModel
        var baseStandings: BaseStandings.State
        
        var standings: [FBTeamStandingsDisplay] = []
        var league: FBLeague? = nil
        var isMLS = false
        
        init(responseModel: FBTeamStandingsResponseModel, displayModel: FBTeamStandingsDisplayModel) {
            self.responseModel = responseModel
            self.baseStandings = BaseStandings.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseStandings(BaseStandings.Action)
        
        case sortStandings
        case showTeamStats(id: Int)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case showTeamStats(model: SportDecodableModel)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseStandings, action: \.baseStandings) { BaseStandings() }
        
        Reduce { state, action in
            switch action {
            case .baseStandings(.initData):
                let displayModel = state.baseStandings.displayModel
                
                // init data
                state.standings = displayModel.standings
                state.league = displayModel.league
                state.isMLS = displayModel.leagueId == Constants.Ids.mls
                
                if state.isMLS {
                    return .send(.baseStandings(.selectHeaderCategory(index: 0, isInit: true)))
                } else {
                    return .send(.sortStandings)
                }
                
            case let .baseStandings(.selectHeaderCategory(index, isInit)):
                let displayModel = state.baseStandings.displayModel
                
                var standings: [FBTeamStandingsDisplay]
                
                if isInit {
                    let entityTeam = displayModel.standings.first { team in
                        // Any first team that matches with any team in entityInfo
                        displayModel.entityInfo.first { $0.teamId == team.team.id } != nil
                    }
                    
                    // When init, if entity's conference is east, set index 1.
                    // Otherwise do nothing, which would be set as default(0).
                    if Constants.Ids.MLSTeam.eastConference.contains(entityTeam?.team.id ?? 0) {
                        state.baseStandings.headerCategorySelectedIndex = 1
                    }
                    
                    standings = displayModel.standings.filter {
                        if entityTeam != nil {
                            Constants.Ids.MLSTeam.eastConference.contains($0.team.id)
                        } else {
                            Constants.Ids.MLSTeam.westConference.contains($0.team.id)
                            
                        }
                    }
                } else {
                    state.baseStandings.headerCategorySelectedIndex = index
                    
                    standings = displayModel.standings.filter {
                        if index == 0 {
                            Constants.Ids.MLSTeam.westConference.contains($0.team.id)
                        } else {
                            Constants.Ids.MLSTeam.eastConference.contains($0.team.id)
                        }
                    }
                }
                
                state.standings = standings
                
                return .send(.sortStandings)
                
            case .baseStandings(.selectCategory):
                return .send(.sortStandings)
                
            case .sortStandings:
                // TODO: 값이 같은경우 다른 카테고리 활용해서 우선순위 정하는 로직 개발
                switch state.baseStandings.categorySelectedIndex {
                case 0: // 승점
//                    state.standings.sort { calculatePoints(data: $0.homeAwayStats) > calculatePoints(data: $1.homeAwayStats) }
                    state.standings.sort { $0.rank < $1.rank }
                    for i in state.standings.indices {
                        state.standings[i].displayRank = state.standings[i].rank
                    }
                case 1: // 승
                    state.standings.sort { $0.homeAwayStats.wins.total > $1.homeAwayStats.wins.total }
                    state.standings.assignCompetitionRank { $0.homeAwayStats.wins.total }
                case 2: // 무
                    state.standings.sort { $0.homeAwayStats.draws.total > $1.homeAwayStats.draws.total }
                    state.standings.assignCompetitionRank { $0.homeAwayStats.draws.total }
                case 3: // 패
                    state.standings.sort { $0.homeAwayStats.loses.total < $1.homeAwayStats.loses.total }
                    state.standings.assignCompetitionRank { $0.homeAwayStats.loses.total }
                case 4: // 경기수
                    state.standings.sort { $0.homeAwayStats.played.total > $1.homeAwayStats.played.total }
                    state.standings.assignCompetitionRank { $0.homeAwayStats.played.total }
                case 5: // 득점
                    state.standings.sort { $0.goalsFor.total > $1.goalsFor.total }
                    state.standings.assignCompetitionRank { $0.goalsFor.total }
                case 6: // 실점
                    state.standings.sort { $0.goalsAgainst.total < $1.goalsAgainst.total }
                    state.standings.assignCompetitionRank { $0.goalsAgainst.total }
                case 7: // 득실차
                    state.standings.sort { $0.goalsFor.total - $0.goalsAgainst.total > $1.goalsFor.total - $1.goalsAgainst.total }
                    state.standings.assignCompetitionRank { $0.goalsFor.total - $0.goalsAgainst.total }
                case 8: // 홈성적
                    state.standings.sort { a, b in
                        let pa = calculateHomePoints(data: a.homeAwayStats)
                        let pb = calculateHomePoints(data: b.homeAwayStats)
                        
                        // 1) points 내림차순
                        if pa != pb {
                            return pa > pb
                        }
                        
                        // 2) wins 내림차순
                        let wa = a.homeAwayStats.wins.home
                        let wb = b.homeAwayStats.wins.home
                        if wa != wb {
                            return wa > wb
                        }
                        
                        // 3) loses 오름차순
                        let la = a.homeAwayStats.loses.home
                        let lb = b.homeAwayStats.loses.home
                        if la != lb {
                            return la < lb
                        }
                        
                        return false
                    }
                    state.standings.assignCompetitionRank { getRecordString(data: $0.homeAwayStats) }
                case 9: // 원정성적
                    state.standings.sort { a, b in
                        let pa = calculateAwayPoints(data: a.homeAwayStats)
                        let pb = calculateAwayPoints(data: b.homeAwayStats)
                        
                        // 1) points 내림차순
                        if pa != pb {
                            return pa > pb
                        }
                        
                        // 2) wins 내림차순
                        let wa = a.homeAwayStats.wins.away
                        let wb = b.homeAwayStats.wins.away
                        if wa != wb {
                            return wa > wb
                        }
                        
                        // 3) loses 오름차순
                        let la = a.homeAwayStats.loses.away
                        let lb = b.homeAwayStats.loses.away
                        if la != lb {
                            return la < lb
                        }
                        
                        return false
                    }
                    state.standings.assignCompetitionRank { getRecordString(data: $0.homeAwayStats, isHome: false) }
                default:
                    break
                }
                
                return .none
                
            case let .showTeamStats(id):
                if case let .db(standings) = state.responseModel.standings {
                    let team = standings.first { $0.team.id == id }
                    let responseModel = FBTeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                    
                    let dataModel: SportDecodableModel = .fbTeamStats(
                        responseModel,
                        ModelConverter.shared.fbTeamStatsConverter(response: responseModel)
                    )
                    
                    return .send(.delegate(.showTeamStats(model: dataModel)))
                }
                
                return .none
                
            case .baseStandings:
                return .none
                
            case .delegate:
                return .none
            } // switch action
            
            func calculatePoints(data: FBTeamStatsFixtures) -> Int {
                return (data.wins.total * 3) + data.draws.total
            }
            
            func calculateHomePoints(data: FBTeamStatsFixtures) -> Int {
                return (data.wins.home * 3) + data.draws.home
            }
            
            func calculateAwayPoints(data: FBTeamStatsFixtures) -> Int {
                return (data.wins.away * 3) + data.draws.away
            }
            
            func getRecordString(data: FBTeamStatsFixtures, isHome: Bool = true) -> String {
                return isHome ? "\(data.wins.home)승 \(data.draws.home)무 \(data.loses.home)패" :
                "\(data.wins.away)승 \(data.draws.away)무 \(data.loses.away)패"
            }
        } // Reduce
    }
}
