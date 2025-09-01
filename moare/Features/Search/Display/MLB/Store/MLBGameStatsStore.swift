//
//  MLBGameStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MLBGameStatsStore {
    typealias BaseGameStats = BaseGameStatsStore<MLBGameStatsDisplayModel>
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let lineScoreItemHeight: CGFloat = 50
        let teamButtonWidth: CGFloat = 120
        
        /* ---------------------
           data state
           --------------------- */
        var baseGameStats = BaseGameStats.State()
        var teamBoxScore: MLBGameBoxscoreTeamData? = nil
        var teamHitters: [(String, MLBGameBoxscoreTeamPlayer)] = []
        var teamPitchers: [(String, MLBGameBoxscoreTeamPlayer)] = []
//        var playersTotalStats: NBAGameBoxScoreStats? = nil
        
        /* ---------------------
           ui state
           --------------------- */
    }
    
    enum Action {
        case baseGameStats(BaseGameStats.Action)
        
        /* ---------------------
           private
           --------------------- */
        case sortHitters
        case sortPitchers
        case setPlayersTotalStats
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseGameStats, action: \.baseGameStats) {
            BaseGameStats()
        }
        
        Reduce { state, action in
            switch action {
            case .baseGameStats(.initData):
                // init with default value
                state.teamBoxScore = nil
                state.teamHitters = []
                state.teamPitchers = []
//                state.playersTotalStats = nil
                
                return .send(.baseGameStats(.selectTeam(0)))
                
            case .baseGameStats(.selectTeam(let index)):
                // set selected team's boxscore
                state.teamBoxScore = if index == 0 {
                    state.baseGameStats.displayModel?.game.boxscore?.teams.home
                } else {
                    state.baseGameStats.displayModel?.game.boxscore?.teams.away
                }
                
                state.teamHitters = state.teamBoxScore?.players
                    .filter { $0.value.position?.abbreviation != "P" && !$0.value.battingOrder.isEmpty }
                    .map { ($0.key, $0.value) } ?? []
                
                
                state.teamPitchers = state.teamBoxScore?.players
                    .filter { $0.value.position?.abbreviation == "P" && !$0.value.allPositions.isEmpty }
                    .map { ($0.key, $0.value) } ?? []
                
                return .run { send in
                    await send(.sortHitters)
                    await send(.sortPitchers)
                    await send(.setPlayersTotalStats)
                }
                
            case .baseGameStats(.selectFirstCategory):
                return .send(.sortHitters)
                
            case .baseGameStats(.selectSecondCategory):
                return .send(.sortPitchers)
                
            case .baseGameStats(_):
                return .none
                
            case .sortHitters:
                switch state.baseGameStats.firstCategorySelectedIndex {
                case 0:
                    state.teamHitters.sort { ($0.1.stats?.batting?.atBats ?? 0) > ($1.1.stats?.batting?.atBats ?? 0) }
                case 1:
                    state.teamHitters.sort { ($0.1.stats?.batting?.hits ?? 0) > ($1.1.stats?.batting?.hits ?? 0) }
                case 2:
                    state.teamHitters.sort { ($0.1.stats?.batting?.homeRuns ?? 0) > ($1.1.stats?.batting?.homeRuns ?? 0) }
                case 3:
                    state.teamHitters.sort { ($0.1.stats?.batting?.rbi ?? 0) > ($1.1.stats?.batting?.rbi ?? 0) }
                case 4:
                    state.teamHitters.sort { ($0.1.stats?.batting?.runs ?? 0) > ($1.1.stats?.batting?.runs ?? 0) }
                case 5:
                    state.teamHitters.sort { ($0.1.stats?.batting?.stolenBases ?? 0) > ($1.1.stats?.batting?.stolenBases ?? 0) }
                case 6:
                    state.teamHitters.sort { ($0.1.stats?.batting?.baseOnBalls ?? 0) > ($1.1.stats?.batting?.baseOnBalls ?? 0) }
                case 7:
                    state.teamHitters.sort { ($0.1.stats?.batting?.strikeOuts ?? 0) > ($1.1.stats?.batting?.strikeOuts ?? 0) }
                case 8:
                    state.teamHitters.sort { (Double($0.1.stats?.batting?.avg ?? "0") ?? 0) > (Double($1.1.stats?.batting?.avg ?? "0") ?? 0) }
                default: break
                }
                
                return .none
                
            case .sortPitchers:
                switch state.baseGameStats.secondCategorySelectedIndex {
                case 0:
                    state.teamPitchers.sort { (Double($0.1.stats?.pitching?.inningsPitched ?? "0") ?? 0) > (Double($1.1.stats?.pitching?.inningsPitched ?? "0") ?? 0) }
                case 1:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.runs ?? 0) > ($1.1.stats?.pitching?.runs ?? 0) }
                case 2:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.earnedRuns ?? 0) > ($1.1.stats?.pitching?.earnedRuns ?? 0) }
                case 3:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.baseOnBalls ?? 0) > ($1.1.stats?.pitching?.baseOnBalls ?? 0) }
                case 4:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.strikeOuts ?? 0) > ($1.1.stats?.pitching?.strikeOuts ?? 0) }
                case 5:
                    state.teamPitchers.sort { ($0.1.stats?.pitching?.hits ?? 0) > ($1.1.stats?.pitching?.hits ?? 0) }
                case 6:
                    state.teamPitchers.sort { (Double($0.1.stats?.pitching?.era ?? "0.0") ?? 0) < (Double($1.1.stats?.pitching?.era ?? "0.0") ?? 0) }
                default: break
                }
                
                return .none
                
            case .setPlayersTotalStats:
                return .none
            }
        }
    }
}
