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
        var baseGameStats = BaseGameStats.State()
        var teamLineup: KBOGameLineup? = nil
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
                state.teamLineup = nil
//                state.playersTotalStats = nil
                
                return .send(.baseGameStats(.selectTeam(0)))
                
            case .baseGameStats(.selectTeam(let index)):
                // set selected team's boxscore
                state.teamLineup = if index == 0 {
                    state.baseGameStats.displayModel?.game.lineup.home
                } else {
                    state.baseGameStats.displayModel?.game.lineup.away
                }
                
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
//                switch state.secondSelectedIndex {
//                case 0:
//                    state.playerStats.sort { $0.statistics.points > $1.statistics.points }
//                case 1:
//                    state.playerStats.sort { $0.statistics.assists > $1.statistics.assists }
//                case 2:
//                    state.playerStats.sort { $0.statistics.reboundsOffensive > $1.statistics.reboundsOffensive }
//                case 3:
//                    state.playerStats.sort { $0.statistics.fieldGoalsAttempted > $1.statistics.fieldGoalsAttempted }
//                case 4:
//                    state.playerStats.sort { $0.statistics.fieldGoalsMade > $1.statistics.fieldGoalsMade }
//                case 5:
//                    state.playerStats.sort { $0.statistics.fieldGoalsPercentage > $1.statistics.fieldGoalsPercentage }
//                case 6:
//                    state.playerStats.sort { $0.statistics.threePointersAttempted > $1.statistics.threePointersAttempted }
//                case 7:
//                    state.playerStats.sort { $0.statistics.threePointersMade > $1.statistics.threePointersMade }
//                case 8:
//                    state.playerStats.sort { $0.statistics.threePointersPercentage > $1.statistics.threePointersPercentage }
//                case 9:
//                    state.playerStats.sort { $0.statistics.freeThrowsAttempted > $1.statistics.freeThrowsAttempted }
//                case 10:
//                    state.playerStats.sort { $0.statistics.freeThrowsMade > $1.statistics.freeThrowsMade }
//                case 11:
//                    state.playerStats.sort { $0.statistics.freeThrowsPercentage > $1.statistics.freeThrowsPercentage }
//                case 12:
//                    state.playerStats.sort { $0.statistics.reboundsDefensive > $1.statistics.reboundsDefensive }
//                case 13:
//                    state.playerStats.sort { $0.statistics.blocks > $1.statistics.blocks }
//                case 14:
//                    state.playerStats.sort { $0.statistics.steals > $1.statistics.steals }
//                case 15:
//                    state.playerStats.sort { $0.statistics.reboundsTotal > $1.statistics.reboundsTotal }
//                case 16:
//                    state.playerStats.sort { $0.statistics.turnovers > $1.statistics.turnovers }
//                case 17:
//                    state.playerStats.sort { $0.statistics.foulsPersonal > $1.statistics.foulsPersonal }
//                case 18:
//                    state.playerStats.sort { $0.statistics.plusMinusPoints > $1.statistics.plusMinusPoints }
//                case 19:
//                    state.playerStats.sort { CalendarUtil.formatHourMinuteToMinutes(time: $0.statistics.minutes) > CalendarUtil.formatHourMinuteToMinutes(time: $1.statistics.minutes) }
//                default: break
//                }
                
                return .none
                
            case .sortPitchers:
                return .none
                
            case .setPlayersTotalStats:
                return .none
            }
        }
    }
}
