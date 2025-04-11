//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBATeamStandingsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let categoryItemHeight: CGFloat = 44
        let firstCategoryItemWidth: CGFloat = 132
        let dataItemWidth: CGFloat = 50
        let categoryFontSize: CGFloat = 15
        let dataFontSize: CGFloat = 15
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBATeamStandingsDisplayModel? = nil
        var standings: [NBATeamStandingsDisplay] = []
        
        /* ---------------------
           ui state
           --------------------- */
        var selectedConferenceIndex = 0
        var selectedCategoryIndex = 1
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: NBATeamStandingsDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        case selectConference(index: Int, isInit: Bool = false)
        case selectCategory(index: Int)
        
        /* ---------------------
           private
           --------------------- */
        case sortStandings
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.selectedConferenceIndex = 0
                state.selectedCategoryIndex = 1
                
                // init data
                state.displayModel = displayModel
                
                let keywords = displayModel.keywords
                // select category that matches with the keyword
                if !keywords.isEmpty {
                    let index = StringConstants.NBA.teamStandingsCategories.firstIndex { category in
                        let keyword = keywords.first { $0.keyword == category }
                        return keyword != nil
                    }
                    
                    if let index {
                        state.selectedCategoryIndex = index
                    }
                }
                
                return .send(.selectConference(index: 0, isInit: true))
                
            case .selectConference(let index, let isInit):
                var standings: [NBATeamStandingsDisplay]
                if isInit {
                    let entityTeam = state.displayModel?.standings.first { team in
                        // Any first team that matches with any team in entityInfo
                        state.displayModel?.entityInfo.first { $0.teamId == team.team.id } != nil
                    }
                    
                    // When init, if entity's conference is east, set index 1.
                    // Otherwise do nothing, which would be set as default(0).
                    if entityTeam?.team.teamConference.lowercased() == "east" {
                        state.selectedConferenceIndex = 1
                    }
                    
                    standings = state.displayModel?.standings.filter {
                        if entityTeam != nil {
                            $0.team.teamConference == entityTeam?.team.teamConference
                        } else {
                            $0.team.teamConference.lowercased() == "west"
                        }
                    } ?? []
                } else {
                    state.selectedConferenceIndex = index
                    
                    standings = state.displayModel?.standings.filter {
                        if index == 0 {
                            $0.team.teamConference.lowercased() == "west"
                        } else {
                            $0.team.teamConference.lowercased() == "east"
                        }
                    } ?? []
                }
                
                state.standings = standings
                
                return .send(.sortStandings)
                
            case .selectCategory(let index):
                state.selectedCategoryIndex = index
                
                return .send(.sortStandings)
                
            case .sortStandings:
                let standings = state.standings
                
                switch state.selectedCategoryIndex {
                case 0:
                    state.standings.sort { calculateGamesBack(standings: standings, team: $0.stats) > calculateGamesBack(standings: standings, team: $1.stats) }
                case 1:
                    state.standings.sort { $0.stats?.winsPct ?? 0 > $1.stats?.winsPct ?? 0 }
                case 2:
                    state.standings.sort { $0.stats?.wins ?? 0 > $1.stats?.wins ?? 0 }
                case 3:
                    state.standings.sort { $0.stats?.losses ?? 0 < $1.stats?.losses ?? 0 }
                case 4:
                    state.standings.sort { $0.stats?.gp ?? 0 > $1.stats?.gp ?? 0 }
                case 5:
                    state.standings.sort { $0.stats?.ptsPG ?? 0 > $1.stats?.ptsPG ?? 0 }
                case 6:
                    state.standings.sort { $0.stats?.plusMinusPG ?? 0 > $1.stats?.plusMinusPG ?? 0 }
                case 7:
                    state.standings.sort { $0.stats?.astPG ?? 0 > $1.stats?.astPG ?? 0 }
                case 8:
                    state.standings.sort { $0.stats?.rebPG ?? 0 > $1.stats?.rebPG ?? 0 }
                case 9:
                    state.standings.sort { $0.stats?.fgPct ?? 0 > $1.stats?.fgPct ?? 0 }
                case 10:
                    state.standings.sort { $0.stats?.fg3Pct ?? 0 > $1.stats?.fg3Pct ?? 0 }
                case 11:
                    state.standings.sort { $0.stats?.ftPct ?? 0 > $1.stats?.ftPct ?? 0 }
                case 12:
                    state.standings.sort { $0.stats?.blkPG ?? 0 > $1.stats?.blkPG ?? 0 }
                case 13:
                    state.standings.sort { $0.stats?.stlPG ?? 0 > $1.stats?.stlPG ?? 0 }
                case 14:
                    state.standings.sort { $0.stats?.tovPG ?? 0 < $1.stats?.tovPG ?? 0 }
                case 15:
                    state.standings.sort { $0.stats?.pfPG ?? 0 < $1.stats?.pfPG ?? 0 }
                default:
                    break
                }
                
                return .none
            } // switch action
            
            // TODO: Should move to util
            func calculateGamesBack(standings: [NBATeamStandingsDisplay], team: NBATeamStats?) -> Double {
                guard let team, let leader = standings.max(by: { $0.stats?.winsPct ?? 0 < $1.stats?.winsPct ?? 0 }), let leader = leader.stats else {
                    return 0
                }
                
                return (Double(leader.wins - team.wins) + Double(team.losses - leader.losses)) / 2.0
            }
        }
    }
}
