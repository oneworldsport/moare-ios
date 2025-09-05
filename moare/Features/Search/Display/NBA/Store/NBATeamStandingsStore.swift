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
        let dataItemWidth: CGFloat = 60
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
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
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
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.selectedConferenceIndex = 0
                state.selectedCategoryIndex = 1
                
                // init data
                state.displayModel = displayModel
                
                state.teamNameDictionary = nameProvider.getDictionary(category: "nba_team")
                
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
                    state.standings.sort { calculateGamesBack(standings: standings, team: $0.stats) < calculateGamesBack(standings: standings, team: $1.stats) }
                case 1:
                    state.standings.sort { $0.stats.winsPct > $1.stats.winsPct }
                case 2:
                    state.standings.sort { $0.stats.wins > $1.stats.wins }
                case 3:
                    state.standings.sort { $0.stats.losses < $1.stats.losses }
                case 4:
                    state.standings.sort { $0.stats.gp > $1.stats.gp }
                case 5:
                    state.standings.sort { $0.stats.ptsPG > $1.stats.ptsPG }
                case 6:
                    state.standings.sort { $0.stats.plusMinusPG > $1.stats.plusMinusPG }
                case 7:
                    state.standings.sort { $0.stats.astPG > $1.stats.astPG }
                case 8:
                    state.standings.sort { $0.stats.rebPG > $1.stats.rebPG }
                case 9:
                    state.standings.sort { $0.stats.fgPct > $1.stats.fgPct }
                case 10:
                    state.standings.sort { $0.stats.fg3Pct > $1.stats.fg3Pct }
                case 11:
                    state.standings.sort { $0.stats.ftPct > $1.stats.ftPct }
                case 12:
                    state.standings.sort { $0.stats.blkPG > $1.stats.blkPG }
                case 13:
                    state.standings.sort { $0.stats.stlPG > $1.stats.stlPG }
                case 14:
                    state.standings.sort { $0.stats.tovPG < $1.stats.tovPG }
                case 15:
                    state.standings.sort { $0.stats.pfPG < $1.stats.pfPG }
                default:
                    break
                }
                
                return .none
            } // switch action
            
            // TODO: Should move to util
            func calculateGamesBack(standings: [NBATeamStandingsDisplay], team: NBATeamStats) -> Double {
                guard let leader = standings.max(by: { $0.stats.winsPct < $1.stats.winsPct }) else {
                    return 0
                }
                
                return Double((leader.stats.wins - team.wins) + (team.losses - leader.stats.losses)) / 2.0
            }
        }
    }
}
