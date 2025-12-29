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
    
    let searchClient = SearchClient()
    
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
        // NOTE: shouldFetch는 최초에 FBGameStats에 진입했을때 받은 데이터로 FBLeagueSchedule데이터 업데이트 해줄때 사용.
        case refreshGame(shouldFetch: Bool = true)
        case selectTitleCategory
        
        case updateDisplayModel(model: SportDecodableModel)
        
        case delegate(Delegate)
    }
    
    enum Delegate {
        case didRefreshGame(model: SportDecodableModel)
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
                
                return .send(.baseGameStats(.selectTeam(isInit: true, index: 0)))
                
            case let .baseGameStats(.selectTeam(isInit, index)):
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
                
                // 선수들의 선발/후보, position 값 설정
                if let lineups {
                    let startXIByPlayerId: [Int: String] = Dictionary(
                        uniqueKeysWithValues: lineups.startXI.map { ($0.player.id, $0.player.pos) }
                    )
                    let substitutesByPlayerId: [Int: String] = Dictionary(
                        uniqueKeysWithValues: lineups.substitutes.map { ($0.player.id, $0.player.pos) }
                    )
                    
                    state.playerStats = state.playerStats.map { stats in
                        let playerId = stats.player.id
                        var updated = stats
                        
                        if let pos = startXIByPlayerId[playerId] {
                            updated.starterSortKey = 0
                            updated.position = pos
                        } else if let pos = substitutesByPlayerId[playerId] {
                            updated.starterSortKey = 1
                            updated.position = pos
                        }
                        
                        return updated
                    }
                }
                
                return .run { [firstCategorySelectedIndex = state.baseGameStats.firstCategorySelectedIndex] send in
                    if isInit {
                        await send(.refreshGame(shouldFetch: false)) // NOTE: 이걸 안해주면 새로고침 누르기 전에는 FBLeagueSchedule 데이터가 업데이트 안됨.
                        await send(.selectTitleCategory)
                    } else {
                        if firstCategorySelectedIndex == -1 {
                            await send(.selectTitleCategory)
                        } else {
                            await send(.sortPlayers)
                        }
                    }
                    
                    await send(.setPlayersTotalStats)
                }
                
            case .baseGameStats(.selectFirstCategory):
                return .send(.sortPlayers)
                
            case .sortPlayers:
                switch state.baseGameStats.firstCategorySelectedIndex {
                case 0:
                    state.playerStats.sort { $0.statistics.first?.games.minutes ?? 0 > $1.statistics.first?.games.minutes ?? 0 }
                case 1:
                    state.playerStats.sort { $0.statistics.first?.goals.total ?? 0 > $1.statistics.first?.goals.total ?? 0 }
                case 2:
                    state.playerStats.sort { $0.statistics.first?.penalty.scored ?? 0 > $1.statistics.first?.penalty.scored ?? 0 }
                case 3:
                    state.playerStats.sort { $0.statistics.first?.goals.assists ?? 0 > $1.statistics.first?.goals.assists ?? 0 }
                case 5:
                    state.playerStats.sort { $0.statistics.first?.shots.total ?? 0 > $1.statistics.first?.shots.total ?? 0 }
                case 6:
                    state.playerStats.sort { $0.statistics.first?.shots.on ?? 0 > $1.statistics.first?.shots.on ?? 0 }
                case 7:
                    state.playerStats.sort { $0.statistics.first?.passes.total ?? 0 > $1.statistics.first?.passes.total ?? 0 }
                case 8:
//                    if state.playerStats.allSatisfy({ $0.statistics.first != nil }) {
//                        state.playerStats.sort {
//                            $0.statistics.first!.dribbles.success.percentage(of: $0.statistics.first!.dribbles.attempts, to: 1) > $1.statistics.first!.dribbles.success.percentage(of: $1.statistics.first!.dribbles.attempts, to: 1)
//                        }
//                    }
                    state.playerStats.sort { $0.statistics.first?.dribbles.success ?? 0 > $1.statistics.first?.dribbles.success ?? 0 }
                case 10:
                    state.playerStats.sort { $0.statistics.first?.tackles.total ?? 0 > $1.statistics.first?.tackles.total ?? 0 }
                case 11:
//                    if state.playerStats.allSatisfy({ $0.statistics.first != nil }) {
//                        state.playerStats.sort {
//                            $0.statistics.first!.duels.won.percentage(of: $0.statistics.first!.duels.total, to: 1) > $1.statistics.first!.duels.won.percentage(of: $1.statistics.first!.duels.total, to: 1)
//                        }
//                    }
                    state.playerStats.sort { $0.statistics.first?.duels.won ?? 0 > $1.statistics.first?.duels.won ?? 0 }
                case 12:
                    state.playerStats.sort { $0.statistics.first?.tackles.interceptions ?? 0 > $1.statistics.first?.tackles.interceptions ?? 0 }
                case 14:
                    state.playerStats.sort { $0.statistics.first?.offsides ?? 0 > $1.statistics.first?.offsides ?? 0 }
                case 15:
                    state.playerStats.sort { $0.statistics.first?.fouls.drawn ?? 0 > $1.statistics.first?.fouls.drawn ?? 0 }
                case 16:
                    state.playerStats.sort { $0.statistics.first?.fouls.committed ?? 0 > $1.statistics.first?.fouls.committed ?? 0 }
                case 17:
                    state.playerStats.sort { $0.statistics.first?.cards.yellow ?? 0 > $1.statistics.first?.cards.yellow ?? 0 }
                case 18:
                    state.playerStats.sort { $0.statistics.first?.cards.red ?? 0 > $1.statistics.first?.cards.red ?? 0 }
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
                
            case .selectTitleCategory:
                // 선발, 후보를 먼저 정렬한 후 각각 출전시간 순으로 정렬
                state.playerStats.sort {
                    // 1) 선발/후보
                    if $0.starterSortKey != $1.starterSortKey {
                        return $0.starterSortKey ?? 0 < $1.starterSortKey ?? 0
                    }
                    // 2) minutes 내림차순
                    return $0.statistics.first?.games.minutes ?? 0 > $1.statistics.first?.games.minutes ?? 0
                }
                
                return .send(.baseGameStats(.selectFirstCategory(-1)))
                
            case let .refreshGame(shouldFetch):
                if shouldFetch {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        let game = displayModel.game
                        
                        let result = try await searchClient.fetchById(
                            season: displayModel.season,
                            category: "football",
                            date: game.fixture.date,
                            dataType: "football_game_stats",
                            leagueId: game.league.id,
                            id: String(game.fixture.id)
                        )
                        
                        await send(.updateDisplayModel(model: result.data))
                        await send(.delegate(.didRefreshGame(model: result.data)))
                    }
                } else {
                    return .run { [displayModel = state.baseGameStats.displayModel] send in
                        let responseModel = FBGameStatsResponseModel(game: displayModel.game)
                        let dataModel: SportDecodableModel = .fbGameStats(responseModel, displayModel)
                            
                        await send(.delegate(.didRefreshGame(model: dataModel)))
                    }
                }
                
            case let .updateDisplayModel(model):
                if case .fbGameStats(_, let displayModel) = model {
                    state.baseGameStats.displayModel = displayModel
                    
                    return .send(.baseGameStats(.initData))
                } else {
                    return .none
                }
                
            case .baseGameStats:
                return .none
                
            case .delegate:
                return .none
            } // switch action
        }
    }
}
