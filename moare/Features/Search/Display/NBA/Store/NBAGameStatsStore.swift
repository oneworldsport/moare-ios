//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBAGameStatsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let firstCategoryItemHeight: CGFloat = 30
        let secondCategoryItemHeight: CGFloat = 36
        let itemWidth: CGFloat = 70
        let firstCategoryFontSize: CGFloat = 14
        let secondCategoryFontSize: CGFloat = 13
        let dataFontSize: CGFloat = 14
        let barWidth: CGFloat = 2
        let lineScoreItemHeight: CGFloat = 50
        let teamButtonWidth: CGFloat = 120
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBAGameStatsDisplayModel? = nil
        var homeTeamLineScore: NBALineScore? = nil
        var awayTeamLineScore: NBALineScore? = nil
        var playerStats: [NBABoxScoreTeamPlayer] = []
        var playersTotalStats: NBAGameBoxScoreStats? = nil
        
        /* ---------------------
           ui state
           --------------------- */
        var firstSelectedIndex = 0
        var secondSelectedIndex = 0
        var selectedTeamIndex = 0
        var shouldScrollCategory = false
        
        /* ---------------------
           etc
           --------------------- */
        var homeTeamId = 0
        var awayTeamId = 0
        var playerNameDictionary: [String: String] = [:]
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: NBAGameStatsDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        case selectTeam(index: Int)
        case selectFirstCategory(index: Int)
        case selectSecondCategory(index: Int)
        
        /* ---------------------
           private
           --------------------- */
        case sortPlayers
        case setPlayersTotalStats
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init with default value
                state.playerStats = []
                state.playersTotalStats = nil
                state.firstSelectedIndex = 0
                state.secondSelectedIndex = 0
                state.selectedTeamIndex = 0
                state.shouldScrollCategory = false
                
                // init data
                state.displayModel = displayModel
                
                state.playerNameDictionary = nameProvider.getDictionary(category: "nba_player")
                state.teamNameDictionary = nameProvider.getDictionary(category: "nba_team")
                
                if let gameSummary = displayModel.game.gameSummary {
                    state.homeTeamId = gameSummary.homeTeamId
                    state.awayTeamId = gameSummary.visitorTeamId
                }
                
                // set lineScore
                state.homeTeamLineScore = displayModel.game.lineScore.first { $0.teamId == state.homeTeamId }
                state.awayTeamLineScore = displayModel.game.lineScore.first { $0.teamId == state.awayTeamId }
                
                if let boxScoreTraditional = displayModel.game.boxScoreTraditional {
                    // set current(home) team's players stats
                    return .send(.selectTeam(index: 0))
                }
                
                return .none
                
            case .selectTeam(let index):
                state.selectedTeamIndex = index
                
                // set selected team's players stats
                state.playerStats = if index == 0 {
                    state.displayModel?.game.boxScoreTraditional?.homeTeam.players ?? []
                } else {
                    state.displayModel?.game.boxScoreTraditional?.awayTeam.players ?? []
                }
                
                return .run { send in
                    await send(.sortPlayers)
                    await send(.setPlayersTotalStats)
                }
                
            case .selectFirstCategory(let index):
                state.shouldScrollCategory = true
                
                let attackCategoriesSize = StringConstants.NBA.gameStatsAttackCategories.count
                let defendCategoriesSize = StringConstants.NBA.gameStatsDefendCategories.count
                
                switch index {
                case 0: state.secondSelectedIndex = 0
                case 1: state.secondSelectedIndex = attackCategoriesSize
                case 2: state.secondSelectedIndex = attackCategoriesSize + defendCategoriesSize
                default: break
                }
                
                state.firstSelectedIndex = index
                
                return .send(.sortPlayers)
                
            case .selectSecondCategory(let index):
                state.shouldScrollCategory = false
                state.secondSelectedIndex = index
                
                let attackCategories = StringConstants.NBA.gameStatsAttackCategories
                let defendCategories = StringConstants.NBA.gameStatsDefendCategories
                
                switch index {
                case attackCategories.indices:
                    state.firstSelectedIndex = 0
                case attackCategories.count..<(attackCategories.count + defendCategories.count):
                    state.firstSelectedIndex = 1
                default:
                    state.firstSelectedIndex = 2
                }
                
                return .send(.sortPlayers)
                
            case .sortPlayers:
                switch state.secondSelectedIndex {
                case 0:
                    state.playerStats.sort { $0.statistics.points > $1.statistics.points }
                case 1:
                    state.playerStats.sort { $0.statistics.assists > $1.statistics.assists }
                case 2:
                    state.playerStats.sort { $0.statistics.reboundsOffensive > $1.statistics.reboundsOffensive }
                case 3:
                    state.playerStats.sort { $0.statistics.fieldGoalsAttempted > $1.statistics.fieldGoalsAttempted }
                case 4:
                    state.playerStats.sort { $0.statistics.fieldGoalsMade > $1.statistics.fieldGoalsMade }
                case 5:
                    state.playerStats.sort { $0.statistics.fieldGoalsPercentage > $1.statistics.fieldGoalsPercentage }
                case 6:
                    state.playerStats.sort { $0.statistics.threePointersAttempted > $1.statistics.threePointersAttempted }
                case 7:
                    state.playerStats.sort { $0.statistics.threePointersMade > $1.statistics.threePointersMade }
                case 8:
                    state.playerStats.sort { $0.statistics.threePointersPercentage > $1.statistics.threePointersPercentage }
                case 9:
                    state.playerStats.sort { $0.statistics.freeThrowsAttempted > $1.statistics.freeThrowsAttempted }
                case 10:
                    state.playerStats.sort { $0.statistics.freeThrowsMade > $1.statistics.freeThrowsMade }
                case 11:
                    state.playerStats.sort { $0.statistics.freeThrowsPercentage > $1.statistics.freeThrowsPercentage }
                case 12:
                    state.playerStats.sort { $0.statistics.reboundsDefensive > $1.statistics.reboundsDefensive }
                case 13:
                    state.playerStats.sort { $0.statistics.blocks > $1.statistics.blocks }
                case 14:
                    state.playerStats.sort { $0.statistics.steals > $1.statistics.steals }
                case 15:
                    state.playerStats.sort { $0.statistics.reboundsTotal > $1.statistics.reboundsTotal }
                case 16:
                    state.playerStats.sort { $0.statistics.turnovers > $1.statistics.turnovers }
                case 17:
                    state.playerStats.sort { $0.statistics.foulsPersonal > $1.statistics.foulsPersonal }
                case 18:
                    state.playerStats.sort { $0.statistics.plusMinusPoints > $1.statistics.plusMinusPoints }
                case 19:
                    state.playerStats.sort { CalendarUtil.formatHourMinuteToMinutes(time: $0.statistics.minutes) > CalendarUtil.formatHourMinuteToMinutes(time: $1.statistics.minutes) }
                default: break
                }
                
                return .none
                
            case .setPlayersTotalStats:
                var playersTotalStats = state.playerStats
                    .compactMap { $0.statistics }
                    .reduce(
                        NBAGameBoxScoreStats()
                    ) { acc, stats in
                        let assists = acc.assists + stats.assists
                        let blocks = acc.blocks + stats.blocks
                        let fieldGoalsAttempted = acc.fieldGoalsAttempted + stats.fieldGoalsAttempted
                        let fieldGoalsMade = acc.fieldGoalsMade + stats.fieldGoalsMade
                        let foulsPersonal = acc.foulsPersonal + stats.foulsPersonal
                        let freeThrowsAttempted = acc.freeThrowsAttempted + stats.freeThrowsAttempted
                        let freeThrowsMade = acc.freeThrowsMade + stats.freeThrowsMade
                        let minutes = CalendarUtil.formatMinutesToHourMinute(min: CalendarUtil.formatHourMinuteToMinutes(time: acc.minutes) + CalendarUtil.formatHourMinuteToMinutes(time: stats.minutes))
                        let points = acc.points + stats.points
                        let reboundsDefensive = acc.reboundsDefensive + stats.reboundsDefensive
                        let reboundsOffensive = acc.reboundsOffensive + stats.reboundsOffensive
                        let reboundsTotal = acc.reboundsTotal + stats.reboundsTotal
                        let steals = acc.steals + stats.steals
                        let threePointersAttempted = acc.threePointersAttempted + stats.threePointersAttempted
                        let threePointersMade = acc.threePointersMade + stats.threePointersMade
                        let turnovers = acc.turnovers + stats.turnovers
                        
                        return NBAGameBoxScoreStats(
                            assists: assists,
                            blocks: blocks,
                            fieldGoalsAttempted: fieldGoalsAttempted,
                            fieldGoalsMade: fieldGoalsMade,
                            foulsPersonal: foulsPersonal,
                            freeThrowsAttempted: freeThrowsAttempted,
                            freeThrowsMade: freeThrowsMade,
                            minutes: minutes,
                            points: points,
                            reboundsDefensive: reboundsDefensive,
                            reboundsOffensive: reboundsOffensive,
                            reboundsTotal: reboundsTotal,
                            steals: steals,
                            threePointersAttempted: threePointersAttempted,
                            threePointersMade: threePointersMade,
                            turnovers: turnovers
                        )
                    }
                
                playersTotalStats.fieldGoalsPercentage = playersTotalStats.fieldGoalsAttempted > 0 ? Double(playersTotalStats.fieldGoalsMade) / Double(playersTotalStats.fieldGoalsAttempted).rounded(to: 3) : 0.0
                
                playersTotalStats.freeThrowsPercentage = playersTotalStats.freeThrowsAttempted > 0 ? Double(playersTotalStats.freeThrowsMade) / Double(playersTotalStats.freeThrowsAttempted).rounded(to: 3) : 0.0
                
                playersTotalStats.threePointersPercentage = playersTotalStats.threePointersAttempted > 0 ? Double(playersTotalStats.threePointersMade) / Double(playersTotalStats.threePointersAttempted).rounded(to: 3) : 0.0
                
                playersTotalStats.plusMinusPoints = state.selectedTeamIndex == 0 ? (state.homeTeamLineScore?.pts ?? 0) - (state.awayTeamLineScore?.pts ?? 0) : (state.awayTeamLineScore?.pts ?? 0) - (state.homeTeamLineScore?.pts ?? 0)
                
                state.playersTotalStats = playersTotalStats
                
                return .none
            } // switch action
        }
    }
}
