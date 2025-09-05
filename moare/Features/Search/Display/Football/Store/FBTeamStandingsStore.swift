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
        var displayModel: FBTeamStandingsDisplayModel? = nil
        var standings: [FBTeamStandingsDisplay] = []
        var league: FBLeague? = nil
        var isMLS = false
        
        /* ---------------------
           ui state
           --------------------- */
        var selectedConferenceIndex = 0
        var selectedCategoryIndex = 0
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        case initData(displayModel: FBTeamStandingsDisplayModel)
        case selectConference(index: Int, isInit: Bool = false)
        case selectCategory(index: Int)
        case sortStandings
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.selectedConferenceIndex = 0
                state.selectedCategoryIndex = 0
                
                // init data
                state.displayModel = displayModel
                state.standings = displayModel.standings
                state.league = displayModel.league
                state.isMLS = displayModel.leagueId == Constants.Ids.mls
                
                switch displayModel.leagueId {
                case Constants.Ids.epl:
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.eplTeamDic)
                case Constants.Ids.laliga:
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.laligaTeamDic)
                case Constants.Ids.bundesliga:
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                case Constants.Ids.ligue1:
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.bundesligaTeamDic)
                case Constants.Ids.seriea:
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.serieaTeamDic)
                case Constants.Ids.mls:
                    state.teamNameDictionary = nameProvider.getDictionary(category: Constants.Keys.mlsTeamDic)
                default: break
                }
                
                let keywords = displayModel.keywords
                
                // select category that matches with the keyword
                if !keywords.isEmpty {
                    let index = StringConstants.Football.teamStandingsCategories.firstIndex { category in
                        let keyword = keywords.first { $0.keyword == category }
                        return keyword != nil
                    }
                    
                    if let index = index {
                        state.selectedCategoryIndex = index
                    }
                }
                
                if state.isMLS {
                    return .send(.selectConference(index: 0, isInit: true))
                } else {
                    return .send(.sortStandings)
                }
                
            case .selectConference(let index, let isInit):
                var standings: [FBTeamStandingsDisplay]
                if isInit {
                    let entityTeam = state.displayModel?.standings.first { team in
                        // Any first team that matches with any team in entityInfo
                        state.displayModel?.entityInfo.first { $0.teamId == team.team.id } != nil
                    }
                    
                    // When init, if entity's conference is east, set index 1.
                    // Otherwise do nothing, which would be set as default(0).
                    if Constants.Ids.MLSTeam.eastConference.contains(entityTeam?.team.id ?? 0) {
                        state.selectedConferenceIndex = 1
                    }
                    
                    standings = state.displayModel?.standings.filter {
                        if entityTeam != nil {
                            Constants.Ids.MLSTeam.eastConference.contains($0.team.id)
                        } else {
                            Constants.Ids.MLSTeam.westConference.contains($0.team.id)
                            
                        }
                    } ?? []
                } else {
                    state.selectedConferenceIndex = index
                    
                    standings = state.displayModel?.standings.filter {
                        if index == 0 {
                            Constants.Ids.MLSTeam.westConference.contains($0.team.id)
                        } else {
                            Constants.Ids.MLSTeam.eastConference.contains($0.team.id)
                        }
                    } ?? []
                }
                
                state.standings = standings
                
                return .send(.sortStandings)
                
            case .selectCategory(let index):
                state.selectedCategoryIndex = index
                
                return .send(.sortStandings)
                
            case .sortStandings:
                // TODO: 값이 같은경우 다른 카테고리 활용해서 우선순위 정하는 로직 개발
                switch state.selectedCategoryIndex {
                case 0:
                    state.standings.sort { calculatePoints(data: $0.homeAwayStats) > calculatePoints(data: $1.homeAwayStats) }
                case 1:
                    state.standings.sort { $0.homeAwayStats.wins.total > $1.homeAwayStats.wins.total }
                case 2:
                    state.standings.sort { $0.homeAwayStats.draws.total > $1.homeAwayStats.draws.total }
                case 3:
                    // reverse
                    state.standings.sort { $0.homeAwayStats.loses.total < $1.homeAwayStats.loses.total }
                case 4:
                    state.standings.sort { $0.homeAwayStats.played.total > $1.homeAwayStats.played.total }
                case 5:
                    state.standings.sort { $0.goalsFor.total > $1.goalsFor.total }
                case 6:
                    // reverse
                    state.standings.sort { $0.goalsAgainst.total < $1.goalsAgainst.total }
                case 7:
                    state.standings.sort { $0.goalsFor.total - $0.goalsAgainst.total > $1.goalsFor.total - $1.goalsAgainst.total }
                case 8:
                    state.standings.sort { calculateHomePoints(data: $0.homeAwayStats) > calculateHomePoints(data: $1.homeAwayStats) }
                case 9:
                    state.standings.sort { calculateAwayPoints(data: $0.homeAwayStats) > calculateAwayPoints(data: $1.homeAwayStats) }
                default:
                    break
                }
                
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
        } // Reduce
    }
}
