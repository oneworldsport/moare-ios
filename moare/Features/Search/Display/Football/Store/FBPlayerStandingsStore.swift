//
//  FBPlayerStandingsStore.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/1/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct FBPlayerStandingsStore {
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let dataItemHeight: CGFloat = 40
        let categoryItemHeight: CGFloat = 40
        let firstCategoryItemWidth: CGFloat = 132
        let itemWidth: CGFloat = 70
        let barWidth: CGFloat = 2
        let categoryFontSize: CGFloat = 15
        let dataFontSize: CGFloat = 15
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: FBPlayerStandingsDisplayModel? = nil
        var standings: [FBPlayerStandingsDisplay] = []
        var league: FBLeague? = nil
        
        /* ---------------------
           ui state
           --------------------- */
        var firstSelectedIndex = 0
        var secondSelectedIndex = 0
        var shouldScrollCategory = false
    }
    
    enum Action {
        case initData(displayModel: FBPlayerStandingsDisplayModel)
        case selectFirstCategory(Int)
        case selectSecondCategory(Int)
        
        /* ---------------------
           private
           --------------------- */
        case sortStandings
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                state.displayModel = displayModel
                state.standings = displayModel.standings
                state.league = displayModel.standings.first?.stats.league
                
                let keywords = displayModel.keywords
                
                // select category that matches with the keyword
                if !keywords.isEmpty {
                    let index = StringConstants.Football.playerStandingsSecondCategories.firstIndex { category in
                        let keyword = keywords.first { $0.keyword == category }
                        return keyword != nil
                    }
                    
                    if let index = index {
                        state.secondSelectedIndex = index
                    }
                }
                
                return .send(.sortStandings)
                
            case .selectFirstCategory(let index):
                state.shouldScrollCategory = true
                
                // should change secondSelectedIndex first as bar moves based on secondSelectedIndex when firstSelectedIndex changes
                switch index {
                case 0: state.secondSelectedIndex = 0
                case 1: state.secondSelectedIndex = StringConstants.Football.playerStandingsAttackCategories.count
                case 2: state.secondSelectedIndex = StringConstants.Football.playerStandingsAttackCategories.count + StringConstants.Football.playerStandingsDefendCategories.count
                default: break
                }
                
                state.firstSelectedIndex = index
                
                return .send(.sortStandings)
                
            case .selectSecondCategory(let index):
                state.shouldScrollCategory = false
                state.secondSelectedIndex = index
                
                switch index {
                case StringConstants.Football.playerStandingsAttackCategories.indices:
                    state.firstSelectedIndex = 0
                case StringConstants.Football.playerStandingsAttackCategories.count..<(StringConstants.Football.playerStandingsAttackCategories.count + StringConstants.Football.playerStandingsDefendCategories.count):
                    state.firstSelectedIndex = 1
                default:
                    state.firstSelectedIndex = 2
                }
                
                return .send(.sortStandings)
                
            case .sortStandings:
                var standings = state.standings
                
                switch state.secondSelectedIndex {
                case 0:
                    standings.sort { $0.stats.goals.total > $1.stats.goals.total }
                case 1:
                    standings.sort { $0.stats.goals.assists > $1.stats.goals.assists }
                case 2:
                    standings.sort { $0.stats.goals.total + $0.stats.goals.assists > $1.stats.goals.total + $1.stats.goals.assists }
                case 3:
                    standings.sort { $0.stats.shots.total > $1.stats.shots.total }
                case 4:
                    standings.sort { $0.stats.shots.on > $1.stats.shots.on }
                case 5:
                    standings.sort { $0.stats.passes.key > $1.stats.passes.key }
                case 6:
                    standings.sort { $0.stats.dribbles.success > $1.stats.dribbles.success }
                case 7:
                    standings.sort { $0.stats.penalty.scored > $1.stats.penalty.scored }
                case 8:
                    standings.sort { $0.stats.tackles.total > $1.stats.tackles.total }
                case 9:
                    standings.sort { $0.stats.duels.won > $1.stats.duels.won }
                case 10:
                    standings.sort { $0.stats.passes.total > $1.stats.passes.total }
                case 11:
                    standings.sort { $0.stats.fouls.committed > $1.stats.fouls.committed }
                case 12:
                    standings.sort { $0.stats.cards.yellow > $1.stats.cards.yellow }
                case 13:
                    standings.sort { $0.stats.cards.red > $1.stats.cards.red }
                case 14:
                    standings.sort { $0.stats.games.appearences > $1.stats.games.appearences }
                case 15:
                    standings.sort { $0.stats.games.lineups > $1.stats.games.lineups }
                case 16:
                    standings.sort { $0.stats.substitutes.substituteIn > $1.stats.substitutes.substituteIn }
                case 17:
                    standings.sort { $0.stats.games.minutes > $1.stats.games.minutes }
                case 18:
                    standings.sort { Double($0.stats.games.rating) ?? 0 > Double($1.stats.games.rating) ?? 0 }
                default:
                    break
                }
                
                state.standings = Array(standings.prefix(20))
                
                return .none
            }
        }
    }
}
