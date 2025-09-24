//
//  KBOGameStatsStore.swift
//  moare
//
//  Created by Mohwa Yoon on 6/10/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KBOGameStatsStore {
    typealias BaseGameStats = BaseGameStatsStore<KBOGameStatsDisplayModel>
    
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
        var baseGameStats: BaseGameStats.State
        
        var teamLineup: KBOGameLineup? = nil
        var teamHitters: [KBOGameHitterStats] = []
        var teamPitchers: [KBOGamePitcherStats] = []
//        var playersTotalStats: NBAGameBoxScoreStats? = nil
        
        init(displayModel: KBOGameStatsDisplayModel) {
            self.baseGameStats = BaseGameStats.State(displayModel: displayModel)
        }
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
        Scope(state: \.baseGameStats, action: \.baseGameStats) { BaseGameStats() }
        
        Reduce { state, action in
            switch action {
            case .baseGameStats(.initData):
                // init with default value
                state.teamLineup = nil
                state.teamHitters = []
                state.teamPitchers = []
//                state.playersTotalStats = nil
                
                return .send(.baseGameStats(.selectTeam(0)))
                
            case .baseGameStats(.selectTeam(let index)):
                // set selected team's boxscore
                state.teamLineup = if index == 0 {
                    state.baseGameStats.displayModel.game.lineup?.home
                } else {
                    state.baseGameStats.displayModel.game.lineup?.away
                }
                
                state.teamHitters = state.teamLineup?.hitters ?? []
                state.teamPitchers = state.teamLineup?.pitchers ?? []
                
                return .run { send in
                    await send(.sortHitters)
                    await send(.sortPitchers)
                    await send(.setPlayersTotalStats)
                }
                
            case .baseGameStats(.selectFirstCategory):
                return .send(.sortHitters)
                
            case .baseGameStats(.selectSecondCategory):
                return .send(.sortPitchers)
                
            case .sortHitters:
                switch state.baseGameStats.firstCategorySelectedIndex {
                case 0:
                    state.teamHitters.sort { Double($0.ab) > Double($1.ab)}
                case 1:
                    state.teamHitters.sort { Double($0.h) > Double($1.h) }
                case 2:
                    state.teamHitters.sort { $0.homeRuns > $1.homeRuns }
                case 3:
                    state.teamHitters.sort { Double($0.rbi) > Double($1.rbi) }
                case 4:
                    state.teamHitters.sort { Double($0.r) > Double($1.r) }
                case 5:
                    state.teamHitters.sort { $0.baseOnBalls > $1.baseOnBalls }
                case 6:
                    state.teamHitters.sort { $0.strikeOuts > $1.strikeOuts }
                case 7:
                    state.teamHitters.sort { $0.groundIntoDoublePlay > $1.groundIntoDoublePlay }
                default: break
                }
                
                return .none
                
            case .sortPitchers:
                switch state.baseGameStats.secondCategorySelectedIndex {
                case 0:
                    state.teamPitchers.sort { (Double($0.ip) ?? 0) > (Double($1.ip) ?? 0) }
                case 1:
                    state.teamPitchers.sort { (Double($0.r) ?? 0) > (Double($1.r) ?? 0) }
                case 2:
                    state.teamPitchers.sort { (Double($0.er) ?? 0) > (Double($1.er) ?? 0) }
                case 3:
                    state.teamPitchers.sort { (Double($0.bb) ?? 0) > (Double($1.bb) ?? 0) }
                case 4:
                    state.teamPitchers.sort { (Double($0.so) ?? 0) > (Double($1.so) ?? 0) }
                case 5:
                    state.teamPitchers.sort { (Double($0.h) ?? 0) > (Double($1.h) ?? 0) }
                default: break
                }
                
                return .none
                
            case .setPlayersTotalStats:
                return .none
                
            case .baseGameStats(_):
                return .none
            }
        }
    }
}
