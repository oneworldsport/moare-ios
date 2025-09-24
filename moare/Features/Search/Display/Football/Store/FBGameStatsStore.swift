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
    typealias BaseGameStats = BaseGameStatsStore<FBGameStatsDisplayModel>
    
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
        var baseGameStats: BaseGameStats.State

        var playerStats: [FBGamePlayerStats] = []
        var lineups: FBGameLineups? = nil
        var coach: FBPerson? = nil
        var playerTotalStats: FBGamePlayerStatsDetail? = nil
        
        init(displayModel: FBGameStatsDisplayModel) {
            self.baseGameStats = BaseGameStats.State(displayModel: displayModel)
        }
    }
    
    enum Action {
        case baseGameStats(BaseGameStats.Action)
        
        case sortPlayers
        case setPlayersTotalStats
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.baseGameStats, action: \.baseGameStats) { BaseGameStats() }
        
        Reduce { state, action in
            switch action {
            case .baseGameStats(.initData):
                // init with default value
                state.playerStats = []
                state.lineups = nil
                state.coach = nil
                state.playerTotalStats = nil

                let displayModel = state.baseGameStats.displayModel
                
                // set current(home) team's players stats
                let homeTeamId = displayModel.game.teams.home.id
                let playersStats = displayModel.game.players.first { $0.team.id == homeTeamId }?.players
                state.playerStats = playersStats ?? []
                
                // set current(home) team's coach, lineups
                let lineups = displayModel.game.lineups.first { $0.team.id == homeTeamId }
                state.lineups = lineups
                state.coach = lineups?.coach
                
                return .run { send in
                    await send(.setPlayersTotalStats)
                    await send(.sortPlayers)
                }
                
            case let .baseGameStats(.selectTeam(index)):
                let displayModel = state.baseGameStats.displayModel
                
                // set selected team's players stats
                let teamId: Int? = switch index {
                case 0: displayModel.game.teams.home.id
                case 1: displayModel.game.teams.away.id
                default: nil
                }
                
                let playersStats = displayModel.game.players.first { teamId != nil && $0.team.id == teamId }?.players
                state.playerStats = playersStats ?? []
                
                // set selected team's coach, lineups
                let lineups = displayModel.game.lineups.first { teamId != nil && $0.team.id == teamId }
                state.lineups = lineups
                state.coach = lineups?.coach
                
                return .run { send in
                    await send(.setPlayersTotalStats)
                    await send(.sortPlayers)
                }
                
            case .baseGameStats(.selectFirstCategory):
                return .send(.sortPlayers)
                
            case .sortPlayers:
                switch state.baseGameStats.firstCategorySelectedIndex {
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
                default: break
                }
                
                return .none
                
            case .setPlayersTotalStats:
                state.playerTotalStats = state.playerStats
                    .compactMap { $0.statistics.first }
                    .reduce(
                        FBGamePlayerStatsDetail()
                    ) { acc, stats in
                        // NOTE: 생성자에 바로 선언하지 않고 프로퍼티를 따로 만들어 생성자에 전달하면 오류가 안난다..?
                        let newShots = FBPlayerStatsShots(
                            total: acc.shots.total + stats.shots.total,
                            on: acc.shots.on + stats.shots.on
                        )
                        
                        let newGoals = FBPlayerStatsGoals(
                            total: acc.goals.total + stats.goals.total,
                            assists: acc.goals.assists + stats.goals.assists
                        )
                        
                        let newPasses = FBGamePlayerStatsPasses(
                            total: acc.passes.total + stats.passes.total,
                            key: acc.passes.key + stats.passes.key
                        )
                        
                        let newTackles = FBPlayerStatsTackles(
                            total: acc.tackles.total + stats.tackles.total,
                            interceptions: acc.tackles.interceptions + stats.tackles.interceptions
                        )
                        
                        let newDuels = FBPlayerStatsDuels(
                            total: acc.duels.total + stats.duels.total,
                            won: acc.duels.won + stats.duels.won
                        )
                        
                        let newDribbles = FBPlayerStatsDribbles(
                            attempts: acc.dribbles.attempts + stats.dribbles.attempts,
                            success: acc.dribbles.success + stats.dribbles.success
                        )
                        
                        let newFouls = FBPlayerStatsFouls(
                            drawn: acc.fouls.drawn + stats.fouls.drawn,
                            committed: acc.fouls.committed + stats.fouls.committed
                        )
                        
                        let newCards = FBPlayerStatsCards(
                            yellow: acc.cards.yellow + stats.cards.yellow,
                            red: acc.cards.red + stats.cards.red
                        )
                        
                        let newPenalty = FBPlayerStatsPenalty(
                            scored: acc.penalty.scored + stats.penalty.scored
                        )
                        
                        return FBGamePlayerStatsDetail(
                            games: FBGamePlayerStatsGames(),
                            offsides: acc.offsides + stats.offsides,
                            shots: newShots,
                            goals: newGoals,
                            passes: newPasses,
                            tackles: newTackles,
                            duels: newDuels,
                            dribbles: newDribbles,
                            fouls: newFouls,
                            cards: newCards,
                            penalty: newPenalty
                        )
                    }
                
                return .none
                
            case .baseGameStats:
                return .none
            } // switch action
        }
    }
}
