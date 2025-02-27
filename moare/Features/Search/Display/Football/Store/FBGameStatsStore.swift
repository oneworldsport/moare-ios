//
//  FBGameStatsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBGameStatsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let categoryItemHeight: CGFloat = 30
        let teamButtonWidth: CGFloat = 120
        let firstItemWidth: CGFloat = 100
        let itemWidth: CGFloat = 70
        let percentageItemWidth: CGFloat = 100
        let barWidth: CGFloat = 2
        let categoryFontSize: CGFloat = 14
        let dataFontSize: CGFloat = 14
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBGameStatsDisplayModel? = nil
        var playerStats: [FBGamePlayerStats] = []
        var lineups: FBGameLineups? = nil
        var coach: FBPerson? = nil
        
        /* ---------------------
           ui state
           --------------------- */
        var firstSelectedIndex = 0
        var secondSelectedIndex = 0
        var selectedTeamIndex = 0
        var shouldScrollCategory = false
    }
    
    enum Action {
        case initData(displayModel: FBGameStatsDisplayModel)
        case selectFirstCategory(Int)
        case selectSecondCategory(Int)
        case selectTeam(Int)
        
        /* ---------------------
           private
           --------------------- */
        case sortPlayers
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                
                // set current(home) team's players stats
                let homeTeamId = displayModel.game.teams.home.id
                let playersStats = displayModel.game.players.first { $0.team.id == homeTeamId }?.players
                state.playerStats = playersStats ?? []
                
                // set current(home) team's coach, lineups
                let lineups = displayModel.game.lineups.first { $0.team.id == homeTeamId }
                state.lineups = lineups
                state.coach = lineups?.coach
                
                return .send(.sortPlayers)
                
            case .selectFirstCategory(let index):
                state.shouldScrollCategory =  true
                
                // should change secondSelectedIndex first as bar moves based on secondSelectedIndex when firstSelectedIndex changes
                switch index {
                case 0: state.secondSelectedIndex = 0
                case 1: state.secondSelectedIndex = StringConstants.Football.gameStatsAttackCategories.count
                case 2: state.secondSelectedIndex = StringConstants.Football.gameStatsAttackCategories.count + StringConstants.Football.gameStatsDefendCategories.count
                default: break
                }
                
                state.firstSelectedIndex = index
                
                return .send(.sortPlayers)
                
            case .selectSecondCategory(let index):
                state.shouldScrollCategory = false
                state.secondSelectedIndex = index
                
                switch index {
                case StringConstants.Football.gameStatsAttackCategories.indices:
                    state.firstSelectedIndex = 0
                case StringConstants.Football.gameStatsAttackCategories.count..<(StringConstants.Football.gameStatsAttackCategories.count + StringConstants.Football.gameStatsDefendCategories.count):
                    state.firstSelectedIndex = 1
                default:
                    state.firstSelectedIndex = 2
                }
                
                return .send(.sortPlayers)
                
            case .selectTeam(let index):
                state.selectedTeamIndex = index
                
                // set selected team's players stats
                let teamId: Int? = switch index {
                case 0: state.displayModel?.game.teams.home.id
                case 1: state.displayModel?.game.teams.away.id
                default: nil
                }
                
                let playersStats = state.displayModel?.game.players.first { teamId != nil && $0.team.id == teamId }?.players
                state.playerStats = playersStats ?? []
                
                // set selected team's coach, lineups
                let lineups = state.displayModel?.game.lineups.first { teamId != nil && $0.team.id == teamId }
                state.lineups = lineups
                state.coach = lineups?.coach
                
                return .send(.sortPlayers)
                
            case .sortPlayers:
                switch state.secondSelectedIndex {
                case 0:
                    state.playerStats.sort { $0.statistics.first?.goals.total ?? 0 > $1.statistics.first?.goals.total ?? 0 }
                case 1:
                    state.playerStats.sort { $0.statistics.first?.penalty.scored ?? 0 > $1.statistics.first?.penalty.scored ?? 0 }
                case 2:
                    state.playerStats.sort { $0.statistics.first?.goals.assists ?? 0 > $1.statistics.first?.goals.assists ?? 0 }
                case 3:
                    state.playerStats.sort { $0.statistics.first?.shots.total ?? 0 > $1.statistics.first?.shots.total ?? 0 }
                case 4:
                    state.playerStats.sort { $0.statistics.first?.shots.on ?? 0 > $1.statistics.first?.shots.on ?? 0 }
                case 5:
                    state.playerStats.sort { $0.statistics.first?.passes.key ?? 0 > $1.statistics.first?.passes.key ?? 0 }
                case 6:
                    if state.playerStats.allSatisfy({ $0.statistics.first != nil }) {
                        state.playerStats.sort {
                            $0.statistics.first!.dribbles.success.percentage(of: $0.statistics.first!.dribbles.attempts, to: 1) > $1.statistics.first!.dribbles.success.percentage(of: $1.statistics.first!.dribbles.attempts, to: 1)
                        }
                    }
                case 7:
                    state.playerStats.sort { $0.statistics.first?.offsides ?? 0 > $1.statistics.first?.offsides ?? 0 }
                case 8:
                    state.playerStats.sort { $0.statistics.first?.tackles.total ?? 0 > $1.statistics.first?.tackles.total ?? 0 }
                case 9:
                    if state.playerStats.allSatisfy({ $0.statistics.first != nil }) {
                        state.playerStats.sort {
                            $0.statistics.first!.duels.won.percentage(of: $0.statistics.first!.duels.total, to: 1) > $1.statistics.first!.duels.won.percentage(of: $1.statistics.first!.duels.total, to: 1)
                        }
                    }
                case 10:
                    state.playerStats.sort { $0.statistics.first?.tackles.interceptions ?? 0 > $1.statistics.first?.tackles.interceptions ?? 0 }
                case 11:
                    state.playerStats.sort { $0.statistics.first?.passes.total ?? 0 > $1.statistics.first?.passes.total ?? 0 }
                case 12:
                    state.playerStats.sort { $0.statistics.first?.fouls.drawn ?? 0 > $1.statistics.first?.fouls.drawn ?? 0 }
                case 13:
                    state.playerStats.sort { $0.statistics.first?.fouls.committed ?? 0 > $1.statistics.first?.fouls.committed ?? 0 }
                case 14:
                    state.playerStats.sort { $0.statistics.first?.cards.yellow ?? 0 > $1.statistics.first?.cards.yellow ?? 0 }
                case 15:
                    state.playerStats.sort { $0.statistics.first?.cards.red ?? 0 > $1.statistics.first?.cards.red ?? 0 }
                case 16:
                    state.playerStats.sort { $0.statistics.first?.games.minutes ?? 0 > $1.statistics.first?.games.minutes ?? 0 }
                case 17:
                    state.playerStats.sort { Double($0.statistics.first?.games.rating ?? "0") ?? 0 > Double($1.statistics.first?.games.rating ?? "0") ?? 0 }
                default:
                    break
                }
                
                return .none
            }
        }
    }
}
