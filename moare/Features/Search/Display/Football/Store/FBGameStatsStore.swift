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
        let barWidth: CGFloat = 2
        let categoryFontSize: CGFloat = 14
        let dataFontSize: CGFloat = 14
        let firstCategory = "선수 이름"
        let firstCategoryList = ["공격지표", "수비지표", "공통지표"]
        let secondCategoryList = ["득점", "어시스트", "공격포인트", "슈팅", "유효슈팅", "태클", "패스", "파울", "경고", "퇴장"]
        let attackCategoryList = ["득점", "어시스트", "공격포인트", "슈팅", "유효슈팅"]
        let defendCategoryList = ["태클", "패스"]
        let commonCategoryList = ["파울", "경고", "퇴장"]
        
        /* ---------------------
           data state
           --------------------- */
        let displayModel: FBGameStatsDisplayModel
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
        case initData
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
            case .initData:
                let displayModel = state.displayModel
                
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
                case 1: state.secondSelectedIndex = state.attackCategoryList.count
                case 2: state.secondSelectedIndex = state.attackCategoryList.count + state.defendCategoryList.count
                default: break
                }
                
                state.firstSelectedIndex = index
                
                return .send(.sortPlayers)
                
            case .selectSecondCategory(let index):
                state.shouldScrollCategory = false
                state.secondSelectedIndex = index
                
                switch index {
                case state.attackCategoryList.indices:
                    state.firstSelectedIndex = 0
                case state.attackCategoryList.count..<(state.attackCategoryList.count + state.defendCategoryList.count):
                    state.firstSelectedIndex = 1
                default:
                    state.firstSelectedIndex = 2
                }
                
                return .send(.sortPlayers)
                
            case .selectTeam(let index):
                state.selectedTeamIndex = index
                
                // set selected team's players stats
                let teamId: Int? = switch index {
                case 0: state.displayModel.game.teams.home.id
                case 1: state.displayModel.game.teams.away.id
                default: nil
                }
                
                let playersStats = state.displayModel.game.players.first { teamId != nil && $0.team.id == teamId }?.players
                state.playerStats = playersStats ?? []
                
                // set selected team's coach
                let coach = state.displayModel.game.lineups.first { teamId != nil && $0.team.id == teamId }?.coach
                state.coach = coach
                
                return .send(.sortPlayers)
                
            case .sortPlayers:
                switch state.secondSelectedIndex {
                case 0:
                    state.playerStats.sort { $0.statistics.first?.goals.total ?? 0 > $1.statistics.first?.goals.total ?? 0 }
                case 1:
                    state.playerStats.sort { $0.statistics.first?.goals.assists ?? 0 > $1.statistics.first?.goals.assists ?? 0 }
                case 2:
                    state.playerStats.sort { ($0.statistics.first?.goals.total ?? 0) + ($0.statistics.first?.goals.assists ?? 0) > ($1.statistics.first?.goals.total ?? 0) + ($1.statistics.first?.goals.assists ?? 0) }
                case 3:
                    state.playerStats.sort { $0.statistics.first?.shots.total ?? 0 > $1.statistics.first?.shots.total ?? 0 }
                case 4:
                    state.playerStats.sort { $0.statistics.first?.shots.on ?? 0 > $1.statistics.first?.shots.on ?? 0 }
                case 5:
                    state.playerStats.sort { $0.statistics.first?.passes.total ?? 0 > $1.statistics.first?.passes.total ?? 0 }
                case 6:
                    state.playerStats.sort { $0.statistics.first?.tackles.total ?? 0 > $1.statistics.first?.tackles.total ?? 0 }
                case 7:
                    state.playerStats.sort { $0.statistics.first?.fouls.committed ?? 0 > $1.statistics.first?.fouls.committed ?? 0 }
                case 8:
                    state.playerStats.sort { $0.statistics.first?.cards.yellow ?? 0 > $1.statistics.first?.cards.yellow ?? 0 }
                case 9:
                    state.playerStats.sort { $0.statistics.first?.cards.red ?? 0 > $1.statistics.first?.cards.red ?? 0 }
                default:
                    break
                }
                
                return .none
            }
        }
    }
}
