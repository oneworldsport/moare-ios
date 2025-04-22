//
//  NBAPlayerInfoStore.swift
//  moare
//
//  Created by Mohwa Yoon on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct NBALeagueTournamentStore {
    let searchClient = SearchClient()
    
    @ObservableState
    struct State {
        /* ---------------------
           constants
           --------------------- */
        let priorityList = [
            1610612760, 1610612763, 1610612743, 1610612746, 1610612747, 1610612750, 1610612745, 1610612744,
            1610612739, 1610612748, 1610612754, 1610612749, 1610612752, 1610612765, 1610612738, 1610612753
        ]
        // 1610612760 okc
        // 1610612763 mem
        // 1610612743 den
        // 1610612746 lac
        // 1610612747 lal
        // 1610612750 min
        // 1610612745 hou
        // 1610612744 gsw
        // 1610612739 cle
        // 1610612748 mia
        // 1610612754 ind
        // 1610612749 mil
        // 1610612752 nyk
        // 1610612765 det
        // 1610612738 bos
        // 1610612753 orl
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBALeagueScheduleDisplayModel? = nil
        
        var westFirstRoundFirstGameList: [NBAGame]? = nil
        var westFirstRoundFirstGameFirstTeamId: Int = 1610612760
        var westFirstRoundFirstGameSecondTeamId: Int = 1610612763
        
        var westFirstRoundSecondGameList: [NBAGame]? = nil
        var westFirstRoundSecondGameFirstTeamId: Int = 1610612743
        var westFirstRoundSecondGameSecondTeamId: Int = 1610612746
        
        var westFirstRoundThirdGameList: [NBAGame]? = nil
        var westFirstRoundThirdGameFirstTeamId: Int = 1610612747
        var westFirstRoundThirdGameSecondTeamId: Int = 1610612750
        
        var westFirstRoundFourthGameList: [NBAGame]? = nil
        var westFirstRoundFourthGameFirstTeamId: Int = 1610612745
        var westFirstRoundFourthGameSecondTeamId: Int = 1610612744
        
        var eastFirstRoundFirstGameList: [NBAGame]? = nil
        var eastFirstRoundFirstGameFirstTeamId: Int = 1610612739
        var eastFirstRoundFirstGameSecondTeamId: Int = 1610612748
        
        var eastFirstRoundSecondGameList: [NBAGame]? = nil
        var eastFirstRoundSecondGameFirstTeamId: Int = 1610612754
        var eastFirstRoundSecondGameSecondTeamId: Int = 1610612749
        
        var eastFirstRoundThirdGameList: [NBAGame]? = nil
        var eastFirstRoundThirdGameFirstTeamId: Int = 1610612752
        var eastFirstRoundThirdGameSecondTeamId: Int = 1610612765
        
        var eastFirstRoundFourthGameList: [NBAGame]? = nil
        var eastFirstRoundFourthGameFirstTeamId: Int = 1610612738
        var eastFirstRoundFourthGameSecondTeamId: Int = 1610612753
        
        var westSecondRoundFirstGameList: [NBAGame]? = nil
        var westSecondRoundFirstGameFirstTeamId: Int? = nil
        var westSecondRoundFirstGameSecondTeamId: Int? = nil
        
        var westSecondRoundSecondGameList: [NBAGame]? = nil
        var westSecondRoundSecondGameFirstTeamId: Int? = nil
        var westSecondRoundSecondGameSecondTeamId: Int? = nil
        
        var eastSecondRoundFirstGameList: [NBAGame]? = nil
        var eastSecondRoundFirstGameFirstTeamId: Int? = nil
        var eastSecondRoundFirstGameSecondTeamId: Int? = nil
        
        var eastSecondRoundSecondGameList: [NBAGame]? = nil
        var eastSecondRoundSecondGameFirstTeamId: Int? = nil
        var eastSecondRoundSecondGameSecondTeamId: Int? = nil
        
        var westFinalRoundGameList: [NBAGame]? = nil
        var westFinalRoundGameFirstTeamId: Int? = nil
        var westFinalRoundGameSecondTeamId: Int? = nil
        
        var eastFinalRoundGameList: [NBAGame]? = nil
        var eastFinalRoundGameFirstTeamId: Int? = nil
        var eastFinalRoundGameSecondTeamId: Int? = nil
        
        var finalRoundGameList: [NBAGame]? = nil
        var finalRoundGameFirstTeamId: Int? = nil
        var finalRoundGameSecondTeamId: Int? = nil
        
        /* ---------------------
           ui state
           --------------------- */
        
        /* ---------------------
           etc
           --------------------- */
        var teamNameDictionary: [String: String] = [:]
    }
    
    enum Action {
        /* ---------------------
           init
           --------------------- */
        case initData(displayModel: NBALeagueScheduleDisplayModel)
        
        /* ---------------------
           view action
           --------------------- */
        
        /* ---------------------
           private
           --------------------- */
    }
    
    @Dependency(\.translatedNameProvider) var nameProvider
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initData(let displayModel):
                // init data
                state.displayModel = displayModel
                
                state.teamNameDictionary = nameProvider.getDictionary(category: "nba_team")
                
                // western first round
                state.westFirstRoundFirstGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612760 && $0.gameSummary?.visitorTeamId == 1610612763) ||
                    ($0.gameSummary?.visitorTeamId == 1610612763 && $0.gameSummary?.homeTeamId == 1610612760)
                }
                state.westFirstRoundSecondGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612743 && $0.gameSummary?.visitorTeamId == 1610612746) ||
                    ($0.gameSummary?.homeTeamId == 1610612746 && $0.gameSummary?.visitorTeamId == 1610612743)
                }
                state.westFirstRoundThirdGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612747 && $0.gameSummary?.visitorTeamId == 1610612750) ||
                    ($0.gameSummary?.homeTeamId == 1610612750 && $0.gameSummary?.visitorTeamId == 1610612747)
                }
                state.westFirstRoundFourthGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612745 && $0.gameSummary?.visitorTeamId == 1610612744) ||
                    ($0.gameSummary?.homeTeamId == 1610612744 && $0.gameSummary?.visitorTeamId == 1610612745)
                }
                
                // eastern first round
                state.eastFirstRoundFirstGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612739 && $0.gameSummary?.visitorTeamId == 1610612748) ||
                    ($0.gameSummary?.homeTeamId == 1610612748 && $0.gameSummary?.visitorTeamId == 1610612739)
                }
                state.eastFirstRoundSecondGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612754 && $0.gameSummary?.visitorTeamId == 1610612749) ||
                    ($0.gameSummary?.homeTeamId == 1610612749 && $0.gameSummary?.visitorTeamId == 1610612754)
                }
                state.eastFirstRoundThirdGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612752 && $0.gameSummary?.visitorTeamId == 1610612765) ||
                    ($0.gameSummary?.homeTeamId == 1610612765 && $0.gameSummary?.visitorTeamId == 1610612752)
                }
                state.eastFirstRoundFourthGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == 1610612738 && $0.gameSummary?.visitorTeamId == 1610612753) ||
                    ($0.gameSummary?.homeTeamId == 1610612753 && $0.gameSummary?.visitorTeamId == 1610612738)
                }
                
                // western second round
                if let westFirstRoundFirstGameSeries = getGameSeries(gameList: state.westFirstRoundFirstGameList) {
                    // western second round first game first team id
                    if westFirstRoundFirstGameSeries.seasonSeries?.homeTeamWins == 4 {
                        state.westSecondRoundFirstGameFirstTeamId = westFirstRoundFirstGameSeries.seasonSeries?.homeTeamId
                    } else if westFirstRoundFirstGameSeries.seasonSeries?.homeTeamLosses == 4 {
                        state.westSecondRoundFirstGameFirstTeamId = westFirstRoundFirstGameSeries.seasonSeries?.visitorTeamId
                    }
                    
                    // western second round first game second team id
                    if let westFirstRoundSecondGameSeries = getGameSeries(gameList: state.westFirstRoundSecondGameList) {
                        if westFirstRoundSecondGameSeries.seasonSeries?.homeTeamWins == 4 {
                            state.westSecondRoundFirstGameSecondTeamId = westFirstRoundSecondGameSeries.seasonSeries?.homeTeamId
                        } else if westFirstRoundSecondGameSeries.seasonSeries?.homeTeamLosses == 4 {
                            state.westSecondRoundFirstGameSecondTeamId = westFirstRoundSecondGameSeries.seasonSeries?.visitorTeamId
                        }
                    }
                    
                    if let first = state.westSecondRoundFirstGameFirstTeamId,
                        let second = state.westSecondRoundFirstGameSecondTeamId {
                        state.westSecondRoundFirstGameList = displayModel.games.filter {
                            ($0.gameSummary?.homeTeamId == first && $0.gameSummary?.visitorTeamId == second) ||
                            ($0.gameSummary?.homeTeamId == second && $0.gameSummary?.visitorTeamId == first)
                        }
                    }
                }
                if let westFirstRoundThirdGameSeries = getGameSeries(gameList: state.westFirstRoundThirdGameList) {
                    // western second round second game first team id
                    if westFirstRoundThirdGameSeries.seasonSeries?.homeTeamWins == 4 {
                        state.westSecondRoundSecondGameFirstTeamId = westFirstRoundThirdGameSeries.seasonSeries?.homeTeamId
                    } else if westFirstRoundThirdGameSeries.seasonSeries?.homeTeamLosses == 4 {
                        state.westSecondRoundSecondGameFirstTeamId = westFirstRoundThirdGameSeries.seasonSeries?.visitorTeamId
                    }
                    
                    // western second round second game second team id
                    if let westFirstRoundFourthGameSeries = getGameSeries(gameList: state.westFirstRoundFourthGameList) {
                        if westFirstRoundFourthGameSeries.seasonSeries?.homeTeamWins == 4 {
                            state.westSecondRoundSecondGameSecondTeamId = westFirstRoundFourthGameSeries.seasonSeries?.homeTeamId
                        } else if westFirstRoundFourthGameSeries.seasonSeries?.homeTeamLosses == 4 {
                            state.westSecondRoundSecondGameSecondTeamId = westFirstRoundFourthGameSeries.seasonSeries?.visitorTeamId
                        }
                    }
                    
                    if let first = state.westSecondRoundSecondGameFirstTeamId,
                        let second = state.westSecondRoundSecondGameSecondTeamId {
                        state.westSecondRoundSecondGameList = displayModel.games.filter {
                            ($0.gameSummary?.homeTeamId == first && $0.gameSummary?.visitorTeamId == second) ||
                            ($0.gameSummary?.homeTeamId == second && $0.gameSummary?.visitorTeamId == first)
                        }
                    }
                }
                
                // eastern second round
                if let eastFirstRoundFirstGameSeries = getGameSeries(gameList: state.eastFirstRoundFirstGameList) {
                    // eastern second round first game first team id
                    if eastFirstRoundFirstGameSeries.seasonSeries?.homeTeamWins == 4 {
                        state.eastSecondRoundFirstGameFirstTeamId = eastFirstRoundFirstGameSeries.seasonSeries?.homeTeamId
                    } else if eastFirstRoundFirstGameSeries.seasonSeries?.homeTeamLosses == 4 {
                        state.eastSecondRoundFirstGameFirstTeamId = eastFirstRoundFirstGameSeries.seasonSeries?.visitorTeamId
                    }
                    
                    // eastern second round first game second team id
                    if let eastFirstRoundSecondGameSeries = getGameSeries(gameList: state.eastFirstRoundSecondGameList) {
                        if eastFirstRoundSecondGameSeries.seasonSeries?.homeTeamWins == 4 {
                            state.eastSecondRoundFirstGameSecondTeamId = eastFirstRoundSecondGameSeries.seasonSeries?.homeTeamId
                        } else if eastFirstRoundSecondGameSeries.seasonSeries?.homeTeamLosses == 4 {
                            state.eastSecondRoundFirstGameSecondTeamId = eastFirstRoundSecondGameSeries.seasonSeries?.visitorTeamId
                        }
                    }
                    
                    if let first = state.eastSecondRoundFirstGameFirstTeamId,
                        let second = state.eastSecondRoundFirstGameSecondTeamId {
                        state.eastSecondRoundFirstGameList = displayModel.games.filter {
                            ($0.gameSummary?.homeTeamId == first && $0.gameSummary?.visitorTeamId == second) ||
                            ($0.gameSummary?.homeTeamId == second && $0.gameSummary?.visitorTeamId == first)
                        }
                    }
                }
                if let eastFirstRoundThirdGameSeries = getGameSeries(gameList: state.eastFirstRoundThirdGameList) {
                    // eastern second round second game first team id
                    if eastFirstRoundThirdGameSeries.seasonSeries?.homeTeamWins == 4 {
                        state.eastSecondRoundSecondGameFirstTeamId = eastFirstRoundThirdGameSeries.seasonSeries?.homeTeamId
                    } else if eastFirstRoundThirdGameSeries.seasonSeries?.homeTeamLosses == 4 {
                        state.eastSecondRoundSecondGameFirstTeamId = eastFirstRoundThirdGameSeries.seasonSeries?.visitorTeamId
                    }
                    
                    // eastern second round second game second team id
                    if let eastFirstRoundFourthGameSeries = getGameSeries(gameList: state.eastFirstRoundFourthGameList) {
                        if eastFirstRoundFourthGameSeries.seasonSeries?.homeTeamWins == 4 {
                            state.eastSecondRoundSecondGameSecondTeamId = eastFirstRoundFourthGameSeries.seasonSeries?.homeTeamId
                        } else if eastFirstRoundFourthGameSeries.seasonSeries?.homeTeamLosses == 4 {
                            state.eastSecondRoundSecondGameSecondTeamId = eastFirstRoundFourthGameSeries.seasonSeries?.visitorTeamId
                        }
                    }
                    
                    if let first = state.eastSecondRoundSecondGameFirstTeamId,
                        let second = state.eastSecondRoundSecondGameSecondTeamId {
                        state.eastSecondRoundSecondGameList = displayModel.games.filter {
                            ($0.gameSummary?.homeTeamId == first && $0.gameSummary?.visitorTeamId == second) ||
                            ($0.gameSummary?.homeTeamId == second && $0.gameSummary?.visitorTeamId == first)
                        }
                    }
                }
                
                // western final round
                if let westSecondRoundFirstGameSeries = getGameSeries(gameList: state.westSecondRoundFirstGameList) {
                    // western final round first team id
                    if westSecondRoundFirstGameSeries.seasonSeries?.homeTeamWins == 4 {
                        state.westFinalRoundGameFirstTeamId = westSecondRoundFirstGameSeries.seasonSeries?.homeTeamId
                    } else if westSecondRoundFirstGameSeries.seasonSeries?.homeTeamLosses == 4 {
                        state.westFinalRoundGameFirstTeamId = westSecondRoundFirstGameSeries.seasonSeries?.visitorTeamId
                    }
                    
                    // western final round second team id
                    if let westSecondRoundSecondGameSeries = getGameSeries(gameList: state.westSecondRoundSecondGameList) {
                        if westSecondRoundSecondGameSeries.seasonSeries?.homeTeamWins == 4 {
                            state.westFinalRoundGameSecondTeamId = westSecondRoundSecondGameSeries.seasonSeries?.homeTeamId
                        } else if westSecondRoundSecondGameSeries.seasonSeries?.homeTeamLosses == 4 {
                            state.westFinalRoundGameSecondTeamId = westSecondRoundSecondGameSeries.seasonSeries?.visitorTeamId
                        }
                    }
                    
                    if let first = state.westFinalRoundGameFirstTeamId,
                        let second = state.westFinalRoundGameSecondTeamId {
                        state.westFinalRoundGameList = displayModel.games.filter {
                            ($0.gameSummary?.homeTeamId == first && $0.gameSummary?.visitorTeamId == second) ||
                            ($0.gameSummary?.homeTeamId == second && $0.gameSummary?.visitorTeamId == first)
                        }
                    }
                }
                
                // eastern final round
                if let eastSecondRoundFirstGameSeries = getGameSeries(gameList: state.eastSecondRoundFirstGameList) {
                    // eastern final round first team id
                    if eastSecondRoundFirstGameSeries.seasonSeries?.homeTeamWins == 4 {
                        state.eastFinalRoundGameFirstTeamId = eastSecondRoundFirstGameSeries.seasonSeries?.homeTeamId
                    } else if eastSecondRoundFirstGameSeries.seasonSeries?.homeTeamLosses == 4 {
                        state.eastFinalRoundGameFirstTeamId = eastSecondRoundFirstGameSeries.seasonSeries?.visitorTeamId
                    }
                    
                    // eastern final round second team id
                    if let eastSecondRoundSecondGameSeries = getGameSeries(gameList: state.eastSecondRoundSecondGameList) {
                        if eastSecondRoundSecondGameSeries.seasonSeries?.homeTeamWins == 4 {
                            state.eastFinalRoundGameSecondTeamId = eastSecondRoundSecondGameSeries.seasonSeries?.homeTeamId
                        } else if eastSecondRoundSecondGameSeries.seasonSeries?.homeTeamLosses == 4 {
                            state.eastFinalRoundGameSecondTeamId = eastSecondRoundSecondGameSeries.seasonSeries?.visitorTeamId
                        }
                    }
                    
                    if let first = state.eastFinalRoundGameFirstTeamId,
                        let second = state.eastFinalRoundGameSecondTeamId {
                        state.eastFinalRoundGameList = displayModel.games.filter {
                            ($0.gameSummary?.homeTeamId == first && $0.gameSummary?.visitorTeamId == second) ||
                            ($0.gameSummary?.homeTeamId == second && $0.gameSummary?.visitorTeamId == first)
                        }
                    }
                }
                
                // final round
                if let westFinalRoundGameSeries = getGameSeries(gameList: state.westFinalRoundGameList) {
                    // final round first team id
                    if westFinalRoundGameSeries.seasonSeries?.homeTeamWins == 4 {
                        state.finalRoundGameFirstTeamId = westFinalRoundGameSeries.seasonSeries?.homeTeamId
                    } else if westFinalRoundGameSeries.seasonSeries?.homeTeamLosses == 4 {
                        state.finalRoundGameFirstTeamId = westFinalRoundGameSeries.seasonSeries?.visitorTeamId
                    }
                    
                    // final round second team id
                    if let eastFinalRoundGameSeries = getGameSeries(gameList: state.eastFinalRoundGameList) {
                        if eastFinalRoundGameSeries.seasonSeries?.homeTeamWins == 4 {
                            state.finalRoundGameSecondTeamId = eastFinalRoundGameSeries.seasonSeries?.homeTeamId
                        } else if eastFinalRoundGameSeries.seasonSeries?.homeTeamLosses == 4 {
                            state.finalRoundGameSecondTeamId = eastFinalRoundGameSeries.seasonSeries?.visitorTeamId
                        }
                    }
                    
                    if let first = state.finalRoundGameFirstTeamId,
                        let second = state.finalRoundGameSecondTeamId {
                        state.finalRoundGameList = displayModel.games.filter {
                            ($0.gameSummary?.homeTeamId == first && $0.gameSummary?.visitorTeamId == second) ||
                            ($0.gameSummary?.homeTeamId == second && $0.gameSummary?.visitorTeamId == first)
                        }
                    }
                }
                
                return .none
            } // switch action
            
            func getGameSeries(gameList: [NBAGame]?) -> NBAGame? {
                return gameList?.max(by: {
                    (($0.seasonSeries?.homeTeamWins ?? 0) + ($0.seasonSeries?.homeTeamLosses ?? 0)) < (($1.seasonSeries?.homeTeamWins ?? 0) + ($1.seasonSeries?.homeTeamLosses ?? 0))
                })
            }
        }
    }
}
