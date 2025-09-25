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
    typealias BaseStandings = BaseTeamStandingsStore<NBATeamStandingsDisplayModel>
    
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
        let responseModel: NBATeamStandingsResponseModel
        var baseStandings: BaseStandings.State
        
        var standings: [NBATeamStandingsDisplay] = []
        
        init(responseModel: NBATeamStandingsResponseModel, displayModel: NBATeamStandingsDisplayModel) {
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
                // init with default value
                state.baseStandings.categorySelectedIndex = 1
                
                return .send(.baseStandings(.selectHeaderCategory(index: 0, isInit: true)))
                
            case let .baseStandings(.selectHeaderCategory(index, isInit)):
                let displayModel = state.baseStandings.displayModel
                
                var standings: [NBATeamStandingsDisplay]
                
                if isInit {
                    let entityTeam = displayModel.standings.first { team in
                        // Any first team that matches with any team in entityInfo
                        displayModel.entityInfo.first { $0.teamId == team.team.id } != nil
                    }
                    
                    // When init, if entity's conference is east, set index 1.
                    // Otherwise do nothing, which would be set as default(0).
                    if entityTeam?.team.teamConference.lowercased() == "east" {
                        state.baseStandings.headerCategorySelectedIndex = 1
                    }
                    
                    standings = displayModel.standings.filter {
                        if entityTeam != nil {
                            $0.team.teamConference == entityTeam?.team.teamConference
                        } else {
                            $0.team.teamConference.lowercased() == "west"
                        }
                    }
                } else {
                    state.baseStandings.headerCategorySelectedIndex = index
                    
                    standings = displayModel.standings.filter {
                        if index == 0 {
                            $0.team.teamConference.lowercased() == "west"
                        } else {
                            $0.team.teamConference.lowercased() == "east"
                        }
                    }
                }
                
                state.standings = standings
                
                return .send(.sortStandings)
                
            case .baseStandings(.selectCategory):
                return .send(.sortStandings)
                
            case .sortStandings:
                let standings = state.standings
                
                switch state.baseStandings.categorySelectedIndex {
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
                
            case let .showTeamStats(id):
                let team = state.responseModel.standings.first { $0.team.id == id }
                let responseModel = NBATeamInfoResponseModel(info: team, lastGame: nil, nextGame: nil)
                
                let dataModel: SportDecodableModel = .nbaTeamStats(
                    responseModel,
                    ModelConverter.shared.nbaTeamStatsConverter(response: responseModel)
                )
                
                return .send(.delegate(.showTeamStats(model: dataModel)))
                
            case .delegate:
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
