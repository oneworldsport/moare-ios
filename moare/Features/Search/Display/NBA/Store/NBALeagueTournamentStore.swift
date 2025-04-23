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
        
        /* ---------------------
           data state
           --------------------- */
        var displayModel: NBALeagueScheduleDisplayModel? = nil
        
        var westFirstRoundFirstGameList: [NBAGame]? = nil
        var westFirstRoundFirstGameFirstTeamId: Int = Constants.Ids.okc
        var westFirstRoundFirstGameSecondTeamId: Int = Constants.Ids.mem
        
        var westFirstRoundSecondGameList: [NBAGame]? = nil
        var westFirstRoundSecondGameFirstTeamId: Int = Constants.Ids.den
        var westFirstRoundSecondGameSecondTeamId: Int = Constants.Ids.lac
        
        var westFirstRoundThirdGameList: [NBAGame]? = nil
        var westFirstRoundThirdGameFirstTeamId: Int = Constants.Ids.lal
        var westFirstRoundThirdGameSecondTeamId: Int = Constants.Ids.min
        
        var westFirstRoundFourthGameList: [NBAGame]? = nil
        var westFirstRoundFourthGameFirstTeamId: Int = Constants.Ids.hou
        var westFirstRoundFourthGameSecondTeamId: Int = Constants.Ids.gsw
        
        var eastFirstRoundFirstGameList: [NBAGame]? = nil
        var eastFirstRoundFirstGameFirstTeamId: Int = Constants.Ids.cle
        var eastFirstRoundFirstGameSecondTeamId: Int = Constants.Ids.mia
        
        var eastFirstRoundSecondGameList: [NBAGame]? = nil
        var eastFirstRoundSecondGameFirstTeamId: Int = Constants.Ids.ind
        var eastFirstRoundSecondGameSecondTeamId: Int = Constants.Ids.mil
        
        var eastFirstRoundThirdGameList: [NBAGame]? = nil
        var eastFirstRoundThirdGameFirstTeamId: Int = Constants.Ids.nyk
        var eastFirstRoundThirdGameSecondTeamId: Int = Constants.Ids.det
        
        var eastFirstRoundFourthGameList: [NBAGame]? = nil
        var eastFirstRoundFourthGameFirstTeamId: Int = Constants.Ids.bos
        var eastFirstRoundFourthGameSecondTeamId: Int = Constants.Ids.orl
        
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
                    ($0.gameSummary?.homeTeamId == Constants.Ids.okc && $0.gameSummary?.visitorTeamId == Constants.Ids.mem) ||
                    ($0.gameSummary?.visitorTeamId == Constants.Ids.mem && $0.gameSummary?.homeTeamId == Constants.Ids.okc)
                }
                state.westFirstRoundSecondGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == Constants.Ids.den && $0.gameSummary?.visitorTeamId == Constants.Ids.lac) ||
                    ($0.gameSummary?.homeTeamId == Constants.Ids.lac && $0.gameSummary?.visitorTeamId == Constants.Ids.den)
                }
                state.westFirstRoundThirdGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == Constants.Ids.lal && $0.gameSummary?.visitorTeamId == Constants.Ids.min) ||
                    ($0.gameSummary?.homeTeamId == Constants.Ids.min && $0.gameSummary?.visitorTeamId == Constants.Ids.lal)
                }
                state.westFirstRoundFourthGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == Constants.Ids.hou && $0.gameSummary?.visitorTeamId == Constants.Ids.gsw) ||
                    ($0.gameSummary?.homeTeamId == Constants.Ids.gsw && $0.gameSummary?.visitorTeamId == Constants.Ids.hou)
                }
                
                // eastern first round
                state.eastFirstRoundFirstGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == Constants.Ids.cle && $0.gameSummary?.visitorTeamId == Constants.Ids.mia) ||
                    ($0.gameSummary?.homeTeamId == Constants.Ids.mia && $0.gameSummary?.visitorTeamId == Constants.Ids.cle)
                }
                state.eastFirstRoundSecondGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == Constants.Ids.ind && $0.gameSummary?.visitorTeamId == Constants.Ids.mil) ||
                    ($0.gameSummary?.homeTeamId == Constants.Ids.mil && $0.gameSummary?.visitorTeamId == Constants.Ids.ind)
                }
                state.eastFirstRoundThirdGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == Constants.Ids.nyk && $0.gameSummary?.visitorTeamId == Constants.Ids.det) ||
                    ($0.gameSummary?.homeTeamId == Constants.Ids.det && $0.gameSummary?.visitorTeamId == Constants.Ids.nyk)
                }
                state.eastFirstRoundFourthGameList = displayModel.games.filter {
                    ($0.gameSummary?.homeTeamId == Constants.Ids.bos && $0.gameSummary?.visitorTeamId == Constants.Ids.orl) ||
                    ($0.gameSummary?.homeTeamId == Constants.Ids.orl && $0.gameSummary?.visitorTeamId == Constants.Ids.bos)
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
